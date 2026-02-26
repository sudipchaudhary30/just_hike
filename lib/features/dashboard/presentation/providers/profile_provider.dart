import 'package:flutter_riverpod/flutter_riverpod.dart';
// TODO: Replace the below import with the actual path to your ApiService if it exists in your project.
// import 'package:your_project_path/services/api_service.dart';

final profileProvider = Provider<UserProfile>((ref) {
  // Replace with actual profile fetching logic
  return UserProfile(name: 'Name');
});

final guidesProvider = FutureProvider<List<Guide>>((ref) async {
  // Ensure ApiService is correctly referenced as a class with a static method, or instantiate it if needed.
  return ApiService().fetchGuides();
});

class UserProfile {
  final String name;
  UserProfile({required this.name});
}

class Guide {
  final String title;
  // Add other fields as needed

  Guide({required this.title});
}

// Temporary definition for ApiService to avoid errors.
// Remove this if you already have ApiService defined elsewhere and import it instead.
class ApiService {
  Future<List<Guide>> fetchGuides() async {
    // Replace with actual API fetching logic
    await Future.delayed(Duration(seconds: 1));
    return [Guide(title: 'Sample Guide')];
  }
}
