import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state_provider.dart';
import '../widgets/error_state_view.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController _noteController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final selection = state.selection;

    return Scaffold(
      appBar: AppBar(title: const Text('Crowdsource / Report')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (selection == null)
            const ErrorStateView(message: 'Complete onboarding to submit reports.', icon: Icons.report_problem_outlined)
          else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Was the schedule accurate?', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('${selection.discoName} • ${selection.areaName}'),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _noteController,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Optional note', hintText: 'Tell us what happened...'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: _sending ? null : () => _submit(context, true),
                            child: _sending
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Yes, it was accurate'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _sending ? null : () => _submit(context, false),
                        child: const Text('No, it was not accurate'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context, bool accurate) async {
    setState(() => _sending = true);
    try {
      await context.read<AppStateProvider>().reportAccuracy(wasAccurate: accurate, note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted.')));
      }
      _noteController.clear();
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }
}
