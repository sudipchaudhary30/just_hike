import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_hike/features/dashboard/domain/entities/package_entity.dart';
import 'package:just_hike/features/dashboard/domain/usecases/packages_usecase.dart';

// State class for packages
class PackagesState {
  final bool isLoading;
  final List<PackageEntity> packages;
  final String? errorMessage;

  PackagesState({
    this.isLoading = false,
    this.packages = const [],
    this.errorMessage,
  });

  PackagesState copyWith({
    bool? isLoading,
    List<PackageEntity>? packages,
    String? errorMessage,
  }) {
    return PackagesState(
      isLoading: isLoading ?? this.isLoading,
      packages: packages ?? this.packages,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// All packages provider
final allPackagesProvider =
    NotifierProvider<AllPackagesNotifier, PackagesState>(() {
      return AllPackagesNotifier();
    });

class AllPackagesNotifier extends Notifier<PackagesState> {
  late final GetAllPackagesUsecase _getAllPackagesUsecase;

  @override
  PackagesState build() {
    _getAllPackagesUsecase = ref.read(getAllPackagesUsecaseProvider);
    fetchPackages();
    return PackagesState();
  }

  Future<void> fetchPackages() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _getAllPackagesUsecase(NoParams());
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (packages) {
        state = state.copyWith(isLoading: false, packages: packages);
      },
    );
  }
}

// Upcoming packages provider
final upcomingPackagesProvider =
    NotifierProvider<UpcomingPackagesNotifier, PackagesState>(() {
      return UpcomingPackagesNotifier();
    });

class UpcomingPackagesNotifier extends Notifier<PackagesState> {
  late final GetUpcomingPackagesUsecase _getUpcomingPackagesUsecase;

  @override
  PackagesState build() {
    _getUpcomingPackagesUsecase = ref.read(getUpcomingPackagesUsecaseProvider);
    fetchPackages();
    return PackagesState();
  }

  Future<void> fetchPackages() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _getUpcomingPackagesUsecase(NoParams());
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (packages) {
        state = state.copyWith(isLoading: false, packages: packages);
      },
    );
  }
}

// Past packages provider
final pastPackagesProvider =
    NotifierProvider<PastPackagesNotifier, PackagesState>(() {
      return PastPackagesNotifier();
    });

class PastPackagesNotifier extends Notifier<PackagesState> {
  late final GetPastPackagesUsecase _getPastPackagesUsecase;

  @override
  PackagesState build() {
    _getPastPackagesUsecase = ref.read(getPastPackagesUsecaseProvider);
    fetchPackages();
    return PackagesState();
  }

  Future<void> fetchPackages() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _getPastPackagesUsecase(NoParams());
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (packages) {
        state = state.copyWith(isLoading: false, packages: packages);
      },
    );
  }
}

// Wishlist provider
final wishlistProvider = NotifierProvider<WishlistNotifier, PackagesState>(
  () {
    return WishlistNotifier();
  },
);

class WishlistNotifier extends Notifier<PackagesState> {
  late final GetWishlistUsecase _getWishlistUsecase;

  @override
  PackagesState build() {
    _getWishlistUsecase = ref.read(getWishlistUsecaseProvider);
    fetchWishlist();
    return PackagesState();
  }

  Future<void> fetchWishlist() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _getWishlistUsecase(NoParams());
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (packages) {
        state = state.copyWith(isLoading: false, packages: packages);
      },
    );
  }
}
