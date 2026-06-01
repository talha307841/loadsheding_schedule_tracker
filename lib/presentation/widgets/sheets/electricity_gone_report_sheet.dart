import 'package:flutter/material.dart';

class ElectricityGoneReportSheet extends StatefulWidget {
  final String areaName;
  final Future<void> Function(DateTime reportedTime, String? reason) onSubmit;

  const ElectricityGoneReportSheet({super.key, required this.areaName, required this.onSubmit});

  @override
  State<ElectricityGoneReportSheet> createState() => _ElectricityGoneReportSheetState();
}

class _ElectricityGoneReportSheetState extends State<ElectricityGoneReportSheet> {
  DateTime _reportedTime = DateTime.now();
  String? _reason;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + 16;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Report outage in ${widget.areaName}', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('When did it go?'),
            subtitle: Text(MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(_reportedTime))),
            trailing: const Icon(Icons.schedule),
            onTap: _pickTime,
          ),
          DropdownButtonFormField<String>(
            value: _reason,
            items: const [
              DropdownMenuItem(value: 'Unscheduled', child: Text('Unscheduled')),
              DropdownMenuItem(value: 'Fault', child: Text('Fault')),
              DropdownMenuItem(value: 'Unknown', child: Text('Unknown')),
            ],
            onChanged: (value) => setState(() => _reason = value),
            decoration: const InputDecoration(labelText: 'Any reason?'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting ? const CircularProgressIndicator() : const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_reportedTime));
    if (picked == null) {
      return;
    }
    setState(() {
      _reportedTime = DateTime(_reportedTime.year, _reportedTime.month, _reportedTime.day, picked.hour, picked.minute);
    });
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await widget.onSubmit(_reportedTime, _reason);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanks! Your report helps others')));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}