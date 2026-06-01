import 'package:flutter/material.dart';

import '../../data/models/load_shedding_slot.dart';

class ScheduleSlotTile extends StatelessWidget {
  final LoadSheddingSlot slot;

  const ScheduleSlotTile({super.key, required this.slot});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt, color: Colors.deepOrange),
          const SizedBox(width: 12),
          Expanded(
            child: Text('${slot.startTime} - ${slot.endTime}', style: Theme.of(context).textTheme.titleMedium),
          ),
          Text(slot.day, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
