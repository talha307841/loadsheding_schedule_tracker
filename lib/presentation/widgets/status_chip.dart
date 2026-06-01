import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final bool isPowerOn;

  const StatusChip({super.key, required this.isPowerOn});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        avatar: Icon(isPowerOn ? Icons.power : Icons.power_off, color: isPowerOn ? Colors.green : Colors.red),
        label: Text(isPowerOn ? 'Power ON' : 'Power OFF'),
      ),
    );
  }
}
