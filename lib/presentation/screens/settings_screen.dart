import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../core/constants/disco_catalog.dart';
import '../../data/models/disco_selection.dart';
import '../providers/app_state_provider.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    _packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final selection = state.selection;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('Notifications'),
              subtitle: const Text('Receive reminders before outages and when power is restored.'),
              value: state.notificationsEnabled,
              onChanged: state.updateNotificationsEnabled,
            ),
          ),
          Card(
            child: SwitchListTile(
              title: const Text('Dark mode'),
              value: state.darkModeEnabled,
              onChanged: state.updateThemeMode,
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Change DISCO / Area'),
              subtitle: Text(selection == null ? 'No area selected' : '${selection.discoName} • ${selection.areaName}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OnboardingScreen()));
              },
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('App version'),
              subtitle: Text(_packageInfo == null ? 'Loading...' : '${_packageInfo!.version}+${_packageInfo!.buildNumber}'),
            ),
          ),
          if (selection != null)
            Card(
              child: ListTile(
                title: const Text('Selected area data'),
                subtitle: Text('${selection.discoName} / ${selection.divisionName} / ${selection.areaName}'),
              ),
            ),
          Card(
            child: ListTile(
              title: const Text('Supported DISCOs'),
              subtitle: Text(DiscoCatalog.discos.map((disco) => disco.name).join(', ')),
            ),
          ),
        ],
      ),
    );
  }
}
