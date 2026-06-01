import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/date_time_utils.dart';
import '../../core/utils/schedule_calculator.dart';
import '../providers/app_state_provider.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/countdown_tile.dart';
import '../widgets/error_state_view.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/status_chip.dart';
import '../widgets/schedule_slot_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final selection = state.selection;
    final schedule = state.schedule;
    final status = state.scheduleStatus;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PowerAlert Pakistan'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: state.refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: state.refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (state.offline) const _OfflineBanner(),
            if (state.loading) const LoadingSkeleton(),
            if (state.error != null) ErrorStateView(message: state.error!, onRetry: state.refresh),
            if (!state.loading && state.error == null && selection != null && schedule != null && status != null) ...[
              _SelectionHeader(selectionName: '${selection.discoName} • ${selection.divisionName} • ${selection.areaName}'),
              const SizedBox(height: 16),
              StatusChip(isPowerOn: status.isPowerOn),
              const SizedBox(height: 16),
              CountdownTile(nextEventAt: status.nextEventAt),
              const SizedBox(height: 16),
              _TodayScheduleCard(schedule: schedule),
              const SizedBox(height: 16),
              _AccuracyCard(
                onYes: () => state.reportAccuracy(wasAccurate: true),
                onNo: () => state.reportAccuracy(wasAccurate: false),
              ),
              const SizedBox(height: 16),
              const BannerAdWidget(),
            ],
            if (!state.loading && state.error == null && (selection == null || schedule == null))
              const ErrorStateView(
                message: 'No schedule available yet. Complete onboarding or wait for schedule sync.',
                icon: Icons.schedule_outlined,
              ),
          ],
        ),
      ),
    );
  }
}

class _SelectionHeader extends StatelessWidget {
  final String selectionName;

  const _SelectionHeader({required this.selectionName});

  @override
  Widget build(BuildContext context) {
    return Text(selectionName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600));
  }
}

class _TodayScheduleCard extends StatelessWidget {
  final dynamic schedule;

  const _TodayScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final today = DateTimeUtils.formatWeekday(DateTime.now());
    final todaySlots = ScheduleCalculator.slotsForDay(schedule, today);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Today\'s schedule', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (todaySlots.isEmpty)
              const ErrorStateView(message: 'No outages scheduled for today.', icon: Icons.wb_sunny_outlined)
            else
              ...todaySlots.map((slot) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ScheduleSlotTile(slot: slot),
                  )),
          ],
        ),
      ),
    );
  }
}

class _AccuracyCard extends StatelessWidget {
  final VoidCallback onYes;
  final VoidCallback onNo;

  const _AccuracyCard({required this.onYes, required this.onNo});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Is this accurate?', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: FilledButton(onPressed: onYes, child: const Text('Yes'))),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(onPressed: onNo, child: const Text('No')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, color: Theme.of(context).colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          Text('Offline mode enabled. Showing cached or fallback schedule.', style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
        ],
      ),
    );
  }
}
