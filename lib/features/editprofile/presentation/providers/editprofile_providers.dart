import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:just_hike/features/editprofile/presentation/view_model/editprofile_viewmodel.dart';

// Provider for the form validation state
final editprofileFormValidationProvider = StateProvider<Map<String, String?>>((
  ref,
) {
  return {'fullName': null, 'email': null, 'phoneNumber': null, 'bio': null};
});

// Provider for selected image path
final selectedImageProvider = StateProvider<String?>((ref) => null);

// Export the viewmodel provider
final editprofileProvider = editprofileViewmodelProvider;
