import '../../core/utils/schedule_calculator.dart';
import '../models/disco_selection.dart';
import '../models/load_shedding_schedule.dart';
import '../models/load_shedding_slot.dart';
import 'firestore_service.dart';

class ScheduleRepository {
  final FirestoreService firestoreService;

  ScheduleRepository(this.firestoreService);

  Future<LoadSheddingSchedule> fetchForSelection(DiscoSelection selection) async {
    final schedule = await firestoreService.fetchSchedule(selection);
    return schedule ?? _buildFallback(selection);
  }

  Future<ScheduleStatus> currentStatus(DiscoSelection selection) async {
    final schedule = await fetchForSelection(selection);
    return ScheduleCalculator.analyze(schedule, DateTime.now());
  }

  List<LoadSheddingSlot> slotsForToday(LoadSheddingSchedule schedule) {
    return ScheduleCalculator.slotsForDay(schedule, ScheduleCalculator.weekdayOrder[DateTime.now().weekday - 1]);
  }

  List<DaySummary> summary(LoadSheddingSchedule schedule) => ScheduleCalculator.weekSummary(schedule);

  LoadSheddingSchedule _buildFallback(DiscoSelection selection) {
    final slots = List.generate(
      7,
      (index) {
        final weekday = ScheduleCalculator.weekdayOrder[index];
        return [
          LoadSheddingSlot(day: weekday, startTime: '08:00', endTime: '10:00'),
          LoadSheddingSlot(day: weekday, startTime: '18:30', endTime: '20:00'),
        ];
      },
    ).expand((element) => element).toList();
    return LoadSheddingSchedule(
      weekStartDate: DateTime.now(),
      areaId: selection.areaId,
      discoId: selection.discoId,
      slots: slots,
    );
  }
}
