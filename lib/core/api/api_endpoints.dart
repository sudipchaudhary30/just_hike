import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Media server URL (for static files like images)
  static const String mediaServerUrl = 'http://10.0.2.2:5050';

  static const bool isPhysicalDevice = false;

  // Your PC IP address (same network as phone)
  static const String compIpAddress = "192.168.1.65";

  /// Set with:
  /// flutter run --dart-define=API_HOST=192.168.1.65
  static const String _apiHostOverride = String.fromEnvironment('API_HOST');

  static String get _host {
    if (_apiHostOverride.isNotEmpty) return _apiHostOverride;
    if (isPhysicalDevice) return compIpAddress;
    if (kIsWeb) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static String get baseUrl => 'http://$_host:5050/api';
  static String get imageBaseUrl => 'http://$_host:5050';

  static const String userLogin = '/auth/login';
  static const String userRegister = '/auth/register';
  static const String updateProfile = '/auth/update-profile';

  static const String getAllPackages = '/treks';

  // Temporary fallback until backend endpoints exist:
  static const String getUpcomingPackages = '/treks';
  static const String getPastPackages = '/treks';
  static const String getWishlist = '/treks';
  static String wishlistToggle(String packageId) =>
      '/treks/$packageId/wishlist';

  // Optional if your backend has these:
  static const String getAllBlogs = '/blogs';
  static const String getAllGuides = '/guides';

  // Profile picture URL helper - following teacher's pattern
  static String profilePicture(String filename) {
    // If already a full URL, return as-is
    if (filename.startsWith('http')) return filename;

    // If filename includes 'uploads/', use it directly
    if (filename.contains('uploads/')) {
      return '$mediaServerUrl/$filename';
    }

    // Otherwise, assume it's in uploads folder
    return '$mediaServerUrl/uploads/$filename';
  }

  // Legacy helper for backward compatibility
  static String getImageUrl(String imagePath) => profilePicture(imagePath);
}
