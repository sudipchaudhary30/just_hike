import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileProvider = Provider<UserProfile>((ref) {
  // Replace with actual profile fetching logic
  return UserProfile(name: 'John Doe');
});

class UserProfile {
  final String name;
  UserProfile({required this.name});
}
