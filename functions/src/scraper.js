const admin = require('firebase-admin');
const cheerio = require('cheerio');
const puppeteer = require('puppeteer');

const DISCO_SOURCES = [
  {
    discoId: 'lesco',
    source: 'https://lesco.pk/loadshedding',
    mode: 'dynamic',
  },
  {
    discoId: 'fesco',
    source: 'https://fesco.com.pk/load-shedding-schedule',
    mode: 'static',
  },
  {
    discoId: 'mepco',
    source: 'https://mepco.com.pk/loadshedding.aspx',
    mode: 'dynamic',
  },
  {
    discoId: 'pesco',
    source: 'https://pesco.gov.pk',
    mode: 'dynamic',
  },
  {
    discoId: 'hesco',
    source: 'https://hesco.gov.pk',
    mode: 'dynamic',
  },
  {
    discoId: 'iesco',
    source: 'https://iesco.com.pk/loadshedding',
    mode: 'static',
  },
];

function normalizeAreaName(value) {
  return String(value || '')
    .trim()
    .replace(/\s+/g, ' ')
    .toLowerCase();
}

function normalizeTime(value) {
  const raw = String(value || '').trim().toLowerCase();
  if (!raw) {
    return null;
  }
  const hhmm = raw.match(/^(\d{1,2}):(\d{2})\s*(am|pm)?$/i);
  if (hhmm) {
    let hours = Number(hhmm[1]);
    const minutes = hhmm[2];
    const meridiem = hhmm[3];
    if (meridiem) {
      const isPm = meridiem.toLowerCase() === 'pm';
      if (hours === 12) {
        hours = isPm ? 12 : 0;
      } else if (isPm) {
        hours += 12;
      }
    }
    return `${String(hours).padStart(2, '0')}:${minutes}`;
  }
  return null;
}

function parseRowsFromHtml(html) {
  const $ = cheerio.load(html);
  const rows = [];

  $('table tr, .schedule-row, li').each((_, element) => {
    const text = $(element).text().replace(/\s+/g, ' ').trim();
    if (!text) {
      return;
    }

    const dayMatch = text.match(/\b(Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday)\b/i);
    const timeMatch = text.match(/(\d{1,2}:\d{2}\s*(?:am|pm)?)[^\d]{1,10}(\d{1,2}:\d{2}\s*(?:am|pm)?)/i);
    const areaMatch = text.match(/area[:\s-]*([A-Za-z0-9\-\/_&. ]{3,})/i);
    const feederMatch = text.match(/feeder(?:\s*code)?[:\s-]*([A-Za-z0-9\-\/_&. ]{2,})/i);

    if (dayMatch && timeMatch) {
      rows.push({
        areaName: normalizeAreaName(areaMatch ? areaMatch[1] : text.slice(0, 40)),
        feederCode: feederMatch ? feederMatch[1].trim() : null,
        day: dayMatch[1],
        startTime: normalizeTime(timeMatch[1]),
        endTime: normalizeTime(timeMatch[2]),
      });
    }
  });

  return rows;
}

async function fetchHtml(source) {
  const response = await fetch(source, { headers: { 'user-agent': 'Mozilla/5.0 PowerAlertPakistan/1.0' } });
  if (!response.ok) {
    throw new Error(`Failed to fetch ${source}: ${response.status}`);
  }
  return response.text();
}

async function fetchDynamicHtml(source) {
  const browser = await puppeteer.launch({ args: ['--no-sandbox', '--disable-setuid-sandbox'] });
  try {
    const page = await browser.newPage();
    await page.goto(source, { waitUntil: 'networkidle2', timeout: 120000 });
    return await page.content();
  } finally {
    await browser.close();
  }
}

async function scrapeSource(sourceConfig) {
  const html = sourceConfig.mode === 'dynamic' ? await fetchDynamicHtml(sourceConfig.source) : await fetchHtml(sourceConfig.source);
  const rows = parseRowsFromHtml(html)
    .filter((row) => row.startTime && row.endTime && row.day)
    .filter((row) => row.areaName);

  return rows;
}

async function scrapeAllDiscos() {
  const discoResults = [];
  const errors = [];

  for (const sourceConfig of DISCO_SOURCES) {
    try {
      const rows = await scrapeSource(sourceConfig);
      discoResults.push({ discoId: sourceConfig.discoId, rows });
    } catch (error) {
      errors.push({ discoId: sourceConfig.discoId, error: error.message });
    }
  }

  return { discoResults, errors, scrapedAt: new Date().toISOString() };
}

function dedupeRows(rows) {
  const seen = new Set();
  const output = [];
  for (const row of rows) {
    const key = [row.areaName, row.feederCode || '', row.day, row.startTime, row.endTime].join('|');
    if (seen.has(key)) {
      continue;
    }
    seen.add(key);
    output.push(row);
  }
  return output;
}

function isValidRow(row) {
  return Boolean(row.areaName && row.day && row.startTime && row.endTime && row.startTime < row.endTime);
}

function getIsoWeekId(date = new Date()) {
  const target = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
  const dayNr = (target.getUTCDay() + 6) % 7;
  target.setUTCDate(target.getUTCDate() - dayNr + 3);
  const firstThursday = new Date(Date.UTC(target.getUTCFullYear(), 0, 4));
  const weekNumber = 1 + Math.round(((target - firstThursday) / 86400000 - 3 + ((firstThursday.getUTCDay() + 6) % 7)) / 7);
  return `${target.getUTCFullYear()}-${String(weekNumber).padStart(2, '0')}`;
}

function buildScrapeResult(discoResults) {
  return discoResults.map(({ discoId, rows }) => ({ discoId, rows: dedupeRows(rows).filter(isValidRow) }));
}

async function loadPreviousSchedule(db, discoId, areaId, weekId) {
  const previousWeekId = shiftWeekId(weekId, -1);
  const snap = await db.collection('discos').doc(discoId).collection('areas').doc(areaId).collection('schedules').doc(previousWeekId).get();
  return snap.exists ? snap.data() : null;
}

function computeChangeRatio(previousRows = [], currentRows = []) {
  if (!previousRows.length) {
    return 0;
  }
  const previousSet = new Set(previousRows.map((row) => [row.areaName, row.day, row.startTime, row.endTime].join('|')));
  const currentSet = new Set(currentRows.map((row) => [row.areaName, row.day, row.startTime, row.endTime].join('|')));
  let changed = 0;
  for (const key of currentSet) {
    if (!previousSet.has(key)) {
      changed += 1;
    }
  }
  return changed / previousSet.size;
}

function shiftWeekId(weekId, deltaWeeks) {
  const [yearString, weekString] = weekId.split('-');
  const year = Number(yearString);
  const week = Number(weekString);
  const date = new Date(Date.UTC(year, 0, 4 + (week - 1 + deltaWeeks) * 7));
  return getIsoWeekId(date);
}

async function publishScrapedSchedules({ db, admin, runAt, result }) {
  const weekId = getIsoWeekId(runAt);
  const publishSummary = [];

  for (const discoResult of buildScrapeResult(result.discoResults)) {
    const rows = discoResult.rows;
    const areas = new Map();
    for (const row of rows) {
      const areaId = row.areaName.replace(/[^a-z0-9]+/g, '_').replace(/^_+|_+$/g, '');
      const areaRows = areas.get(areaId) || [];
      areaRows.push(row);
      areas.set(areaId, areaRows);
    }

    for (const [areaId, areaRows] of areas.entries()) {
      const validRows = areaRows.filter(isValidRow);
      if (!validRows.length) {
        continue;
      }

      const previous = await loadPreviousSchedule(db, discoResult.discoId, areaId, weekId);
      const changeRatio = computeChangeRatio(previous?.slots || [], validRows);
      const pendingReview = changeRatio > 0.4;
      const scheduleRef = db.collection('discos').doc(discoResult.discoId).collection('areas').doc(areaId).collection('schedules').doc(weekId);
      const payload = {
        weekStartDate: admin.firestore.Timestamp.fromDate(runAt),
        discoId: discoResult.discoId,
        areaId,
        slots: validRows,
        status: pendingReview ? 'pending_review' : 'published',
        source: 'scraper',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      if (!pendingReview) {
        await scheduleRef.set(payload, { merge: true });
      } else {
        await scheduleRef.set(payload, { merge: true });
        await markAdminAlert(admin, {
          discoId: discoResult.discoId,
          areaId,
          weekId,
          changeRatio,
        });
      }

      publishSummary.push({ discoId: discoResult.discoId, areaId, rows: validRows.length, status: pendingReview ? 'pending_review' : 'published' });
    }
  }

  await logScrapeRun(db, {
    status: result.errors.length ? 'partial_success' : 'success',
    rowsScraped: publishSummary.reduce((sum, item) => sum + item.rows, 0),
    errors: result.errors,
    runAt,
  });

  return { weekId, publishSummary, errors: result.errors };
}

async function logScrapeRun(db, payload) {
  const logId = `${Date.now()}`;
  await db.collection('logs').doc(logId).set({
    ...payload,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

async function markAdminAlert(adminSdk, payload) {
  await adminSdk.messaging().send({
    topic: 'admin_alerts',
    notification: {
      title: 'PowerAlert Pakistan admin alert',
      body: `Schedule changed more than 40% for ${payload.discoId}/${payload.areaId}`,
    },
    data: {
      discoId: payload.discoId,
      areaId: payload.areaId,
      weekId: payload.weekId,
      changeRatio: String(payload.changeRatio),
    },
  }).catch(() => null);
}

async function logOutageEvent(db, payload) {
  await db.collection('outage_events').doc(payload.eventId).set({
    ...payload,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });
}

function areaStatusRef(db, discoId, areaId) {
  return db.collection('discos').doc(discoId).collection('areas').doc(areaId);
}

module.exports = {
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
};
