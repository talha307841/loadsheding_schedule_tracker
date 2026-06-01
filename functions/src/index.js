const admin = require('firebase-admin');
const { onRequest } = require('firebase-functions/v2/https');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const { onDocumentCreated, onDocumentUpdated } = require('firebase-functions/v2/firestore');

const {
  buildScrapeResult,
  scrapeAllDiscos,
  publishScrapedSchedules,
  computeChangeRatio,
  getIsoWeekId,
  logScrapeRun,
  loadPreviousSchedule,
  areaStatusRef,
  logOutageEvent,
  markAdminAlert,
} = require('./scraper');

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

exports.scrapeSchedulesScheduled = onSchedule('every 6 hours', async () => {
  const runAt = new Date();
  const result = await scrapeAllDiscos();
  await publishScrapedSchedules({ db, admin, runAt, result });
});

exports.scrapeSchedulesManual = onRequest(async (req, res) => {
  try {
    if (req.method !== 'POST' && req.method !== 'GET') {
      res.status(405).json({ error: 'Method not allowed' });
      return;
    }
    const expectedSecret = process.env.ADMIN_TRIGGER_SECRET;
    if (expectedSecret && req.headers['x-admin-trigger-secret'] !== expectedSecret) {
      res.status(401).json({ error: 'Unauthorized' });
      return;
    }
    const result = await scrapeAllDiscos();
    const summary = await publishScrapedSchedules({ db, admin, runAt: new Date(), result });
    res.status(200).json(summary);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

exports.onOutageReportCreated = onDocumentCreated('outage_reports/{reportId}', async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    return;
  }

  const report = snapshot.data();
  const areaId = report.areaId;
  const discoId = report.discoId;
  const now = admin.firestore.Timestamp.now();
  const fifteenMinutesAgo = admin.firestore.Timestamp.fromMillis(Date.now() - 15 * 60 * 1000);

  const recentReports = await db
    .collection('outage_reports')
    .where('areaId', '==', areaId)
    .where('reportedAt', '>=', fifteenMinutesAgo)
    .get();

  const currentTrust = await ensureUserTrust(db, report.userId);
  if (currentTrust.trustScore <= 0 || currentTrust.unverifiedReports >= 10) {
    await snapshot.ref.update({ ignored: true, ignoredReason: 'low_trust' });
    return;
  }

  await db.collection('users').doc(report.userId).set({
    last_report_area: areaId,
    last_report_at: now,
    updatedAt: now,
    trust_score: currentTrust.trustScore,
    unverified_reports: currentTrust.unverifiedReports,
  }, { merge: true });

  if (recentReports.size >= 3) {
    const eventDoc = db.collection('outage_events').doc();
    await eventDoc.set({
      areaId,
      discoId,
      createdAt: now,
      type: 'unscheduled_outage',
      reportCount: recentReports.size,
      source: 'multiple_user_reports',
    });

    await areaStatusRef(db, discoId, areaId).set({
      status: 'unscheduled_outage',
      updatedAt: now,
      source: 'cloud_function',
    }, { merge: true });

    await admin.messaging().send({
      topic: `area_${discoId}_${areaId}`,
      notification: {
        title: 'PowerAlert Pakistan',
        body: '⚡ Unscheduled outage reported in your area by multiple users',
      },
      data: {
        areaId,
        discoId,
        eventId: eventDoc.id,
      },
    }).catch(() => null);

    await logOutageEvent(db, {
      areaId,
      discoId,
      eventId: eventDoc.id,
      type: 'unscheduled_outage',
      reportCount: recentReports.size,
    });

    await db.collection('users').doc(report.userId).set({
      trust_score: Math.max(0, currentTrust.trustScore - 1),
      updatedAt: now,
    }, { merge: true });
  }
});

exports.onOutageReportUpdated = onDocumentUpdated('outage_reports/{reportId}', async (event) => {
  const before = event.data?.before?.data();
  const after = event.data?.after?.data();
  if (!before || !after) {
    return;
  }

  if (before.moderationStatus === after.moderationStatus) {
    return;
  }

  if (after.moderationStatus === 'inaccurate') {
    const userRef = db.collection('users').doc(after.userId);
    const snap = await userRef.get();
    const currentTrust = Number(snap.data()?.trust_score ?? 100);
    await userRef.set({
      trust_score: Math.max(0, currentTrust - 1),
      unverified_reports: Number(snap.data()?.unverified_reports ?? 0) + 1,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
  }
});

async function ensureUserTrust(dbInstance, userId) {
  const userRef = dbInstance.collection('users').doc(userId);
  const snap = await userRef.get();
  if (!snap.exists) {
    await userRef.set({ trust_score: 100, unverified_reports: 0, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
    return { trustScore: 100, unverifiedReports: 0 };
  }
  const data = snap.data() || {};
  return {
    trustScore: Number(data.trust_score ?? 100),
    unverifiedReports: Number(data.unverified_reports ?? 0),
  };
}
