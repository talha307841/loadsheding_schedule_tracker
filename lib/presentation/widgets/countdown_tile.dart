import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/utils/date_time_utils.dart';

class CountdownTile extends StatelessWidget {
  final DateTime? nextEventAt;

  const CountdownTile({super.key, required this.nextEventAt});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Next outage countdown', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (nextEventAt == null)
              const Text('No upcoming outage detected.')
            else
              StreamBuilder<int>(
                stream: Stream.periodic(const Duration(seconds: 1), (tick) => tick),
                builder: (context, snapshot) {
                  final remaining = nextEventAt!.difference(DateTime.now());
                  final label = remaining.isNegative ? 'Now' : DateTimeUtils.formatDuration(remaining);
                  return Text(label, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700));
                },
              ),
          ],
        ),
      ),
    );
  }
}
