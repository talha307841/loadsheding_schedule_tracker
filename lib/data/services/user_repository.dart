import '../models/app_preferences.dart';
import '../models/app_user_profile.dart';
import '../models/disco_selection.dart';
import 'firestore_service.dart';

class UserRepository {
  final FirestoreService firestoreService;

  UserRepository(this.firestoreService);

  Future<void> syncProfile({
    required String userId,
    required AppPreferences preferences,
  }) async {
    final selection = preferences.selection;
    await firestoreService.upsertUserProfile(
      AppUserProfile(
        userId: userId,
        notificationsEnabled: preferences.notificationsEnabled,
        darkModeEnabled: preferences.darkModeEnabled,
        discoId: selection?.discoId,
        areaId: selection?.areaId,
        areaName: selection?.areaName,
        divisionName: selection?.divisionName,
      ),
    );
  }

  DiscoSelection? normalizeSelection(DiscoSelection? selection) => selection;
}
