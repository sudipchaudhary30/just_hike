import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_hike/features/editprofile/presentation/state/editprofile_state.dart';

final editprofileViewmodelProvider = NotifierProvider<EditprofileViewmodel, EditprofileState>(
  () => EditprofileViewmodel(),
);

class EditprofileViewmodel extends Notifier<EditprofileState> {
  @override
  EditprofileState build() {
    return EditprofileState.initial();
  }

  Future<void> updateProfile({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String bio,
    File? profilePicture,
  }) async {
    state = state.copyWith(status: EditprofileStatus.loading);
    
    try {
      // TODO: Implement actual profile update logic
      await Future.delayed(const Duration(seconds: 2));
      
      state = state.copyWith(
        status: EditprofileStatus.success,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        bio: bio,
      );
    } catch (e) {
      state = state.copyWith(
        status: EditprofileStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(status: EditprofileStatus.initial, errorMessage: null);
  }
}