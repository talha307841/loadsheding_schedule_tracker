import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../data/services/analytics_service.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/disco_catalog.dart';
import '../../core/utils/schedule_calculator.dart';
import '../../data/models/app_preferences.dart';
import '../../data/models/disco_selection.dart';
import '../../data/models/load_shedding_schedule.dart';
import '../../data/repositories/report_repository.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/ad_service.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/services/notification_service.dart';

class AppStateProvider extends ChangeNotifier {
  final LocalStorageService localStorageService;
  final ScheduleRepository scheduleRepository;
  final UserRepository userRepository;
  final ReportRepository reportRepository;

  AppStateProvider({
    required this.localStorageService,
    required this.scheduleRepository,
    required this.userRepository,
    required this.reportRepository,
  });

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  AppPreferences _preferences = AppPreferences.defaults();
  LoadSheddingSchedule? _schedule;
  ScheduleStatus? _scheduleStatus;
  bool _loading = true;
  bool _offline = false;
  String? _error;
  bool _bannerReady = false;
  bool _adLoading = false;

  AppPreferences get preferences => _preferences;
  LoadSheddingSchedule? get schedule => _schedule;
  ScheduleStatus? get scheduleStatus => _scheduleStatus;
  bool get loading => _loading;
  bool get offline => _offline;
  String? get error => _error;
  BannerAd? get bannerAd => AdService.instance.bannerAd;
  bool get bannerReady => _bannerReady;
  bool get hasSelection => _preferences.selection != null;
  DiscoSelection? get selection => _preferences.selection;
  bool get notificationsEnabled => _preferences.notificationsEnabled;
  bool get darkModeEnabled => _preferences.darkModeEnabled;

  Future<void> initialize() async {
    _preferences = localStorageService.loadPreferences();
    await FirestoreService.instance.configureIfNeeded();
    await NotificationService.instance.initialize();
    await AdService.instance.initialize();
    await _ensureAnonymousAuth();
    _listenConnectivity();
    await _loadSchedule();
    _loadBannerAd();
    if (_preferences.selection != null) {
      await _syncUser();
    }
    _loading = false;
    notifyListeners();
  }

  void _listenConnectivity() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      _offline = result.contains(ConnectivityResult.none);
      notifyListeners();
    });
  }

  Future<void> _ensureAnonymousAuth() async {
    if (!FirestoreService.instance.isConfigured) {
      return;
    }
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  }

  Future<void> _loadSchedule() async {
    final selection = _preferences.selection;
    if (selection == null) {
      _schedule = null;
      _scheduleStatus = null;
      return;
    }
    _schedule = await scheduleRepository.fetchForSelection(selection);
    _scheduleStatus = await scheduleRepository.currentStatus(selection);
    await _scheduleNotificationsForUpcomingOutages();
  }

  Future<void> refresh() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _loadSchedule();
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> saveSelection(DiscoSelection selection, {bool showInterstitial = true}) async {
    final nextPreferences = _preferences.copyWith(
      selection: selection,
      onboardingComplete: true,
    );
    _preferences = nextPreferences;
    await localStorageService.savePreferences(nextPreferences);
    await _syncUser();
    await AnalyticsService.instance.logSelectionChange(discoId: selection.discoId, areaId: selection.areaId);
    await _loadSchedule();
    if (showInterstitial) {
      await AdService.instance.showInterstitialIfAvailable();
    }
    notifyListeners();
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    _preferences = _preferences.copyWith(notificationsEnabled: enabled);
    await localStorageService.savePreferences(_preferences);
    await NotificationService.instance.setLocalNotificationPermission(enabled);
    await _syncUser();
    notifyListeners();
  }

  Future<void> updateThemeMode(bool darkModeEnabled) async {
    _preferences = _preferences.copyWith(darkModeEnabled: darkModeEnabled);
    await localStorageService.savePreferences(_preferences);
    await _syncUser();
    notifyListeners();
  }

  Future<void> resyncSelection(DiscoSelection selection) async {
    await saveSelection(selection, showInterstitial: true);
  }

  Future<void> reportAccuracy({required bool wasAccurate, String? note}) async {
    final selection = _preferences.selection;
    if (selection == null) {
      return;
    }
    await reportRepository.submitAccurateCheck(
      discoId: selection.discoId,
      areaId: selection.areaId,
      areaName: selection.areaName,
      wasAccurate: wasAccurate,
      note: note,
    );
    await AnalyticsService.instance.logReportSubmitted(wasAccurate: wasAccurate, areaId: selection.areaId);
  }

  Future<void> _syncUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }
    await userRepository.syncProfile(userId: currentUser.uid, preferences: _preferences);
  }

  Future<void> _scheduleNotificationsForUpcomingOutages() async {
    if (!_preferences.notificationsEnabled || _schedule == null || _preferences.selection == null) {
      return;
    }
    final selection = _preferences.selection!;
    final now = DateTime.now();
    final status = ScheduleCalculator.analyze(_schedule!, now);
    final nextEventAt = status.nextEventAt;
    if (nextEventAt == null || nextEventAt.isBefore(now)) {
      return;
    }

    final nextOutage = status.nextOutageSlot;
    if (nextOutage == null) {
      return;
    }

    final end = DateTime(nextEventAt.year, nextEventAt.month, nextEventAt.day, int.parse(nextOutage.endTime.split(':')[0]), int.parse(nextOutage.endTime.split(':')[1]));
    await NotificationService.instance.scheduleOutageReminder(
      id: selection.areaId.hashCode.abs(),
      outageStartsAt: nextEventAt,
      outageEndsAt: end,
      areaName: selection.areaName,
    );
  }

  void _loadBannerAd() {
    if (_adLoading) {
      return;
    }
    _adLoading = true;
    AdService.instance.loadBanner(
      onLoaded: () {
        _bannerReady = true;
        notifyListeners();
      },
      onFailed: (_) {
        _bannerReady = false;
        notifyListeners();
      },
    );
    AdService.instance.loadInterstitial();
  }

  Future<void> disposeResources() async {
    await _connectivitySubscription?.cancel();
    AdService.instance.dispose();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
