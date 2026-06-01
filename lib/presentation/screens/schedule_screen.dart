import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/schedule_calculator.dart';
import '../providers/app_state_provider.dart';
import '../widgets/error_state_view.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/schedule_slot_tile.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final schedule = state.schedule;

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Schedule')),
      body: state.loading
          ? const LoadingSkeleton()
          : schedule == null
              ? const ErrorStateView(message: 'No schedule found for the selected area.', icon: Icons.event_busy_outlined)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ...ScheduleCalculator.weekSummary(schedule).map((summary) => Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(summary.day, style: Theme.of(context).textTheme.titleLarge),
                                    Chip(label: Text('${summary.outageMinutes} min outage')),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (summary.slots.isEmpty)
                                  const Text('No outages scheduled.'),
                                if (summary.slots.isNotEmpty)
                                  ...summary.slots.map((slot) => Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: ScheduleSlotTile(slot: slot),
                                      )),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
    );
  }
}
