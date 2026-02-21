import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_hike/core/error/failures.dart';
// Add import if NetworkFailure is defined elsewhere, e.g.:
// import 'package:just_hike/core/error/network_failure.dart';
import 'package:just_hike/features/dashboard/data/repositories/packages_repository.dart'
    as data_repo;
import 'package:just_hike/features/dashboard/domain/entities/package_entity.dart';
import 'package:just_hike/features/dashboard/domain/usecases/packages_usecase.dart'
    as usecase;

// State classes for UI
class TrekPackagesState {
  final List<PackageEntity> treks;
  final bool isLoading;
  final String? errorMessage;

  TrekPackagesState({
    required this.treks,
    this.isLoading = false,
    this.errorMessage,
  });
}

class MyBookingState {
  final List<PackageEntity> packages;
  final bool isLoading;
  final String? errorMessage;

  MyBookingState({
    required this.packages,
    this.isLoading = false,
    this.errorMessage,
  });
}

// Provider for trek packages (all packages)
final trekPackagesProvider = FutureProvider<TrekPackagesState>((ref) async {
  final repository = ref.read(data_repo.packagesRepositoryProvider);

  final result = await repository.getAllPackages();

  return result.fold(
    (failure) => TrekPackagesState(
      treks: [],
      errorMessage: _mapFailureToMessage(failure),
    ),
    (packages) => TrekPackagesState(treks: packages),
  );
});

// Provider for my bookings
final myBookingProvider = FutureProvider<MyBookingState>((ref) async {
  // You can implement this later when you have the endpoint
  return MyBookingState(packages: []);
});

// Helper function to map failures to user-friendly messages
String _mapFailureToMessage(Failure failure) {
  if (failure is ApiFailure) {
    return failure.message;
  } else if (failure is NetworkFailure) {
    return 'Network error. Please check your connection.';
  } else {
    return 'An unexpected error occurred.';
  }
}

// Define NetworkFailure if it doesn't exist
class NetworkFailure extends Failure {
  NetworkFailure([String message = 'Network error']) : super(message);
}
