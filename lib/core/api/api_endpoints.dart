import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Media server URL (for static files like images)
  static const String mediaServerUrl = 'http://10.0.2.2:5050';

  static const bool isPhysicalDevice = false;

  // Your PC IP address (same network as phone)
  static const String compIpAddress = "172.25.0.126";

  /// API base url
  static String get baseUrl {
    if (isPhysicalDevice) {
      return 'http://$compIpAddress:5050/api';
    }

    if (kIsWeb) {
      return 'http://localhost:5050/api';
    } else if (Platform.isAndroid) {
      // Android Emulator
      return 'http://10.0.2.2:5050/api';
    } else {
      // iOS simulator / desktop
      return 'http://localhost:5050/api';
    }
  }

  /// Image base url (static file server)
  static String get imageBaseUrl {
    if (isPhysicalDevice) {
      return 'http://$compIpAddress:5050';
    }

    if (kIsWeb) {
      return 'http://localhost:5050';
    } else if (Platform.isAndroid) {
      // Android Emulator
      return 'http://10.0.2.2:5050';
    } else {
      return 'http://localhost:5050';
    }
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String user = '/register';
  static const String userLogin = '/auth/login';
  static const String userRegister = '/auth/register';
  static const String updateProfile = '/auth/update-profile';

  // Package/Trek endpoints
  static const String getAllPackages = '/treks';
  static const String getPackageById = '/treks/:id';

  // These do not exist in backend; keep if you implement later
  static const String getUpcomingPackages = '/bookings';
  static const String getPastPackages = '/bookings';
  static const String getWishlist = '/packages/wishlist';
  static String wishlistToggle(String packageId) =>
      '/packages/$packageId/wishlist';

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
