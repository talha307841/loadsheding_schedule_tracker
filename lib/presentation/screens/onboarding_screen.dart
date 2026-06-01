import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/disco_catalog.dart';
import '../../data/models/disco_selection.dart';
import '../providers/app_state_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  DiscoOption? _selectedDisco;
  DivisionOption? _selectedDivision;
  String? _selectedArea;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final discos = DiscoCatalog.discos;
    final divisions = _selectedDisco?.divisions ?? const <DivisionOption>[];
    final areas = _selectedDivision?.areas ?? const <String>[];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _HeroCard(theme: theme),
              const SizedBox(height: 24),
              DropdownButtonFormField<DiscoOption>(
                value: _selectedDisco,
                items: discos
                    .map((disco) => DropdownMenuItem(value: disco, child: Text(disco.name)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDisco = value;
                    _selectedDivision = null;
                    _selectedArea = null;
                  });
                },
                decoration: const InputDecoration(labelText: 'Select DISCO'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<DivisionOption>(
                value: _selectedDivision,
                items: divisions
                    .map((division) => DropdownMenuItem(value: division, child: Text(division.name)))
                    .toList(),
                onChanged: _selectedDisco == null
                    ? null
                    : (value) {
                        setState(() {
                          _selectedDivision = value;
                          _selectedArea = null;
                        });
                      },
                decoration: const InputDecoration(labelText: 'Select Division'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedArea,
                items: areas.map((area) => DropdownMenuItem(value: area, child: Text(area))).toList(),
                onChanged: _selectedDivision == null ? null : (value) => setState(() => _selectedArea = value),
                decoration: const InputDecoration(labelText: 'Select Feeder / Area'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _canContinue() && !_saving ? _completeOnboarding : null,
                  icon: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.arrow_forward),
                  label: const Text('Continue'),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your selected area is stored locally and synced to Firestore when available.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canContinue() => _selectedDisco != null && _selectedDivision != null && _selectedArea != null;

  Future<void> _completeOnboarding() async {
    setState(() => _saving = true);
    final disco = _selectedDisco!;
    final division = _selectedDivision!;
    final area = _selectedArea!;
    await context.read<AppStateProvider>().saveSelection(
          DiscoSelection(
            discoId: disco.id,
            discoName: disco.name,
            divisionName: division.name,
            areaName: area,
            areaId: area.toLowerCase().replaceAll(' ', '_'),
          ),
        );
    if (mounted) {
      Navigator.of(context).maybePop();
      setState(() => _saving = false);
    }
  }
}

class _HeroCard extends StatelessWidget {
  final ThemeData theme;

  const _HeroCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.bolt_rounded, color: Colors.white, size: 42),
          const SizedBox(height: 16),
          Text('PowerAlert Pakistan', style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Choose your DISCO and area to see a live load shedding schedule.', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }
}
