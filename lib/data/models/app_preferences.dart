import '../../data/models/disco_selection.dart';

class AppPreferences {
  final DiscoSelection? selection;
  final bool onboardingComplete;
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final String? fcmToken;

  const AppPreferences({
    required this.selection,
    required this.onboardingComplete,
    required this.notificationsEnabled,
    required this.darkModeEnabled,
    this.fcmToken,
  });

  factory AppPreferences.defaults() => const AppPreferences(
        selection: null,
        onboardingComplete: false,
        notificationsEnabled: true,
        darkModeEnabled: false,
      );

  AppPreferences copyWith({
    DiscoSelection? selection,
    bool? onboardingComplete,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    String? fcmToken,
  }) {
    return AppPreferences(
      selection: selection ?? this.selection,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  Map<String, dynamic> toMap() => {
        'selection': selection?.toMap(),
        'onboardingComplete': onboardingComplete,
        'notificationsEnabled': notificationsEnabled,
        'darkModeEnabled': darkModeEnabled,
        'fcmToken': fcmToken,
      };

  factory AppPreferences.fromMap(Map<String, dynamic> map) {
    final selectionMap = map['selection'];
    return AppPreferences(
      selection: selectionMap is Map<String, dynamic> ? DiscoSelection.fromMap(selectionMap) : null,
      onboardingComplete: map['onboardingComplete'] as bool? ?? false,
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      darkModeEnabled: map['darkModeEnabled'] as bool? ?? false,
      fcmToken: map['fcmToken'] as String?,
    );
  }
}
