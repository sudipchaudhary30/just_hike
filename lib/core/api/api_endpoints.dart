import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Media server URL (for static files like images)
  // Set this to your computer's IP address for physical device, or 10.0.2.2 for Android emulator
  static const String mediaServerUrl =
      'http://192.168.1.65:5050'; // <-- CHANGE THIS TO YOUR PC IP

  // Set to true if running on a physical device
  static const bool isPhysicalDevice = false;

  // Your PC IP address (same network as phone)
  static const String compIpAddress =
      "192.168.1.65"; // <-- CHANGE THIS TO YOUR PC IP

  /// Set with:
  /// flutter run --dart-define=API_HOST=192.168.1.65
  static const String _apiHostOverride = String.fromEnvironment('API_HOST');

  static String get _host {
    if (_apiHostOverride.isNotEmpty) return _apiHostOverride;
    if (isPhysicalDevice) return compIpAddress;
    if (kIsWeb) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    return compIpAddress; // Default to PC IP instead of localhost
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

  static const String getAllBlogs = '/blogs';
  static const String getAllGuides = '/guides';

  // Universal image URL helper - works for all images
  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';

    // If already a full URL, replace localhost with PC IP
    if (path.startsWith('http://localhost')) {
      return path.replaceFirst('http://localhost', 'http://192.168.1.65');
    }
    if (path.startsWith('http')) return path;

    // Remove any file:// prefix
    if (path.startsWith('file://')) {
      path = path.replaceFirst('file://', '');
    }

    // Ensure path starts with a slash for consistency
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    return '$mediaServerUrl$path';
  }

  // Alias for getImageUrl to match your MyTripsScreen usage
  static String getFullImageUrl(String path) {
    return getImageUrl(path);
  }

  // Profile picture URL helper
  static String profilePicture(String filename) {
    return getImageUrl(filename);
  }

  // Trek image URL helper
  static String trekImage(String? filename) {
    return getImageUrl(filename);
  }

  // Thumbnail image URL helper
  static String thumbnailImage(String? filename) {
    return getImageUrl(filename);
  }

  static const String staticBaseUrl =
      'http://10.0.2.2:5050'; // or your server's IP/domain

  static String getImageUrlSimple(String path) {
    if (path.startsWith('http')) return path;
    return '$staticBaseUrl$path';
  }

  static const String emulatorBaseUrl =
      'http://10.0.2.2:5050'; // Use 10.0.2.2 for Android emulator

  static String getImageUrlV2(String path) {
    if (path.startsWith('http')) return path;
    return '$emulatorBaseUrl$path';
  }
}
