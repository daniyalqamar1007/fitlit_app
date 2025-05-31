import 'package:flutter/foundation.dart';
import '../model/avatar_model.dart';
import '../services/avatar_service.dart';

enum AvatarGenerationStatus { initial, loading, success, error }

class AvatarController {
  final AvatarService _avatarService = AvatarService();

  final ValueNotifier<AvatarGenerationStatus> statusNotifier =
      ValueNotifier<AvatarGenerationStatus>(AvatarGenerationStatus.initial);
  final ValueNotifier<String?> generatedAvatarNotifier =
      ValueNotifier<String?>(null);
  final ValueNotifier<String> errorNotifier = ValueNotifier<String>('');

  Future<AvatarGenerationResponse> generateAvatar({
    String? shirtId,
    String? accessories_id,
    String? pantId,
    String? shoeId,
    String? profile,
    required String? token,
  }) async {
    try {
      statusNotifier.value = AvatarGenerationStatus.loading;
      errorNotifier.value = '';
      print("profilepiture");
print(profile);
      final response = await _avatarService.generateAvatar(
        shirtId: shirtId,
        accessroies_id: accessories_id,
        pantId: pantId,
        shoeId: shoeId,
        token: token,
        profile:profile


      );
      print(response.avatar);

      if (response.avatar != null && response.avatar!.isNotEmpty) {
        generatedAvatarNotifier.value = response.avatar;
        statusNotifier.value = AvatarGenerationStatus.success;
      } else {
        statusNotifier.value = AvatarGenerationStatus.error;
        errorNotifier.value = 'No avatar returned from server';
      }

      return response;
    } catch (e) {
      statusNotifier.value = AvatarGenerationStatus.error;
      errorNotifier.value = e.toString();
      throw e;
    }
  }

  void clearGeneratedAvatar() {
    generatedAvatarNotifier.value = null;
    statusNotifier.value = AvatarGenerationStatus.initial;
    errorNotifier.value = '';
  }

  void dispose() {
    statusNotifier.dispose();
    generatedAvatarNotifier.dispose();
    errorNotifier.dispose();
  }
}
