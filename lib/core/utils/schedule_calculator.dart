import '../constants/disco_catalog.dart';
import '../../data/models/load_shedding_schedule.dart';
import '../../data/models/load_shedding_slot.dart';
import 'date_time_utils.dart';

class ScheduleStatus {
  final bool isPowerOn;
  final DateTime? nextEventAt;
  final LoadSheddingSlot? currentSlot;
  final LoadSheddingSlot? nextOutageSlot;

  const ScheduleStatus({
    required this.isPowerOn,
    required this.nextEventAt,
    required this.currentSlot,
    required this.nextOutageSlot,
  });
}

class ScheduleCalculator {
  static const List<String> weekdayOrder = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static ScheduleStatus analyze(LoadSheddingSchedule schedule, DateTime now) {
    final todayName = DateTimeUtils.formatWeekday(now);
    final todaySlots = schedule.slots.where((slot) => slot.day == todayName).toList();

    for (final slot in todaySlots) {
      final start = DateTimeUtils.parseHHmm(slot.startTime, baseDate: now);
      final end = DateTimeUtils.parseHHmm(slot.endTime, baseDate: now);
      if (now.isAfter(start) && now.isBefore(end)) {
        return ScheduleStatus(
          isPowerOn: false,
          nextEventAt: end,
          currentSlot: slot,
          nextOutageSlot: slot,
        );
      }
      if (now.isBefore(start)) {
        return ScheduleStatus(
          isPowerOn: true,
          nextEventAt: start,
          currentSlot: null,
          nextOutageSlot: slot,
        );
      }
    }

    final upcoming = _nextOutage(schedule, now);
    return ScheduleStatus(
      isPowerOn: true,
      nextEventAt: upcoming?.startsAt,
      currentSlot: null,
      nextOutageSlot: upcoming?.slot,
    );
  }

  static List<LoadSheddingSlot> slotsForDay(LoadSheddingSchedule schedule, String day) {
    final slots = schedule.slots.where((slot) => slot.day == day).toList();
    slots.sort((a, b) => a.startTime.compareTo(b.startTime));
    return slots;
  }

  static List<DaySummary> weekSummary(LoadSheddingSchedule schedule) {
    return weekdayOrder.map((day) {
      final daySlots = slotsForDay(schedule, day);
      var outageMinutes = 0;
      for (final slot in daySlots) {
        final start = DateTimeUtils.parseHHmm(slot.startTime);
        final end = DateTimeUtils.parseHHmm(slot.endTime);
        outageMinutes += end.difference(start).inMinutes.abs();
      }
      return DaySummary(day: day, outageMinutes: outageMinutes, slots: daySlots);
    }).toList();
  }

  static _UpcomingSlot? _nextOutage(LoadSheddingSchedule schedule, DateTime now) {
    final orderedDays = List<String>.from(weekdayOrder);
    final currentIndex = orderedDays.indexOf(DateTimeUtils.formatWeekday(now));
    if (currentIndex == -1) {
      return null;
    }

    for (var offset = 0; offset < orderedDays.length; offset++) {
      final day = orderedDays[(currentIndex + offset) % orderedDays.length];
      final candidateDay = DateTime(now.year, now.month, now.day).add(Duration(days: offset));
      final slots = slotsForDay(schedule, day);
      for (final slot in slots) {
        final start = DateTimeUtils.parseHHmm(slot.startTime, baseDate: candidateDay);
        if (start.isAfter(now)) {
          return _UpcomingSlot(slot: slot, startsAt: start);
        }
      }
    }
    return null;
  }
}

class _UpcomingSlot {
  final LoadSheddingSlot slot;
  final DateTime startsAt;

  const _UpcomingSlot({required this.slot, required this.startsAt});
}

class DaySummary {
  final String day;
  final int outageMinutes;
  final List<LoadSheddingSlot> slots;

  const DaySummary({required this.day, required this.outageMinutes, required this.slots});
}
