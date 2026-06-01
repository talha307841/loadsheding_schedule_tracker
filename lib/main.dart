import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/repositories/report_repository.dart';
import 'data/repositories/schedule_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/services/firestore_service.dart';
import 'data/services/local_storage_service.dart';
import 'presentation/providers/app_state_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localStorage = await LocalStorageService.create();
  final firestoreService = FirestoreService.instance;
  final scheduleRepository = ScheduleRepository(firestoreService);
  final userRepository = UserRepository(firestoreService);
  final reportRepository = ReportRepository(firestoreService);

  final appState = AppStateProvider(
    localStorageService: localStorage,
    scheduleRepository: scheduleRepository,
    userRepository: userRepository,
    reportRepository: reportRepository,
  );
  await appState.initialize();

  runApp(
    ChangeNotifierProvider<AppStateProvider>.value(
      value: appState,
      child: const PowerAlertApp(),
    ),
  );
}
