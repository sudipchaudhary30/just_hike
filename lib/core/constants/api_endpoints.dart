import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // Base URL for your backend - change this based on your environment
  static const String _baseUrl = 'http://10.0.2.2:5050'; // For Android emulator

  // For physical device, use your computer's IP
  // static const String _baseUrl = 'http://192.168.1.65:5050';

  // For iOS simulator
  // static const String _baseUrl = 'http://localhost:5050';

  // API endpoints
  static const String userLogin = '/auth/login';
  static const String userRegister = '/auth/register';
  static const String updateProfile = '/auth/update-profile';
  static const String getAllPackages = '/treks';

  // Universal image URL helper - works for all images
  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';

    // If already a full URL, return as-is
    if (path.startsWith('http')) return path;

    // Remove any file:// prefix
    if (path.startsWith('file://')) {
      path = path.replaceFirst('file://', '');
    }

    // If path starts with '/', just add base URL
    if (path.startsWith('/')) {
      return '$_baseUrl$path';
    }

    // Otherwise add slash and base URL
    return '$_baseUrl/$path';
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
}
