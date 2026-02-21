import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_hike/core/api/api_client.dart';
import 'package:just_hike/core/error/failures.dart';
import 'package:just_hike/core/services/connectivity/networkinfo.dart';
import 'package:just_hike/features/dashboard/data/datasources/remote/packages_remote_datasource.dart';
import 'package:just_hike/features/dashboard/data/repositories/packages_repository.dart';
import 'package:just_hike/features/dashboard/data/repositories/packages_repository.dart' as data_repo;
import 'package:just_hike/features/dashboard/domain/entities/package_entity.dart';
import 'package:just_hike/features/dashboard/domain/repositories/packages_repository.dart';
import 'package:just_hike/core/api/api_endpoints.dart';

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  final connectivity = ref.read(connectivityProvider);
  return _DefaultNetworkInfo(connectivity);
});

class _DefaultNetworkInfo implements NetworkInfo {
  final Connectivity _connectivity;
  _DefaultNetworkInfo(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final dynamic result = await _connectivity.checkConnectivity();

    if (result is List<ConnectivityResult>) {
      return result.any((r) => r != ConnectivityResult.none);
    }
    if (result is ConnectivityResult) {
      return result != ConnectivityResult.none;
    }
    return false;
  }
}

final packagesRepositoryProvider = Provider<IPackagesRepository>((ref) {
  final remoteDataSource = ref.read(packagesRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return data_repo.PackagesRepository(
    remoteDataSource: remoteDataSource,
    networkInfo: networkInfo,
  );
});

final getAllPackagesUsecaseProvider = Provider<GetAllPackagesUsecase>((ref) {
  final repository = ref.read(packagesRepositoryProvider);
  final apiClient = ref.read(apiClientProvider);
  return GetAllPackagesUsecase(repository, apiClient);
});

final getUpcomingPackagesUsecaseProvider = Provider<GetUpcomingPackagesUsecase>(
  (ref) {
    final repository = ref.read(packagesRepositoryProvider);
    return GetUpcomingPackagesUsecase(repository);
  },
);

final getPastPackagesUsecaseProvider = Provider<GetPastPackagesUsecase>((ref) {
  final repository = ref.read(packagesRepositoryProvider);
  return GetPastPackagesUsecase(repository);
});

final getWishlistUsecaseProvider = Provider<GetWishlistUsecase>((ref) {
  final repository = ref.read(packagesRepositoryProvider);
  return GetWishlistUsecase(repository);
});

final toggleWishlistUsecaseProvider = Provider<ToggleWishlistUsecase>((ref) {
  final repository = ref.read(packagesRepositoryProvider);
  return ToggleWishlistUsecase(repository);
});

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}

class GetAllPackagesUsecase extends UseCase<List<PackageEntity>, NoParams> {
  final IPackagesRepository _repository;
  final ApiClient _apiClient;

  GetAllPackagesUsecase(this._repository, this._apiClient);

  @override
  Future<Either<Failure, List<PackageEntity>>> call(NoParams params) async {
    final response = await _apiClient.get(ApiEndpoints.getAllPackages);
    print('TREKS RESPONSE: ${response.data}');
    return _repository.getAllPackages();
  }
}

class GetUpcomingPackagesUsecase
    extends UseCase<List<PackageEntity>, NoParams> {
  final IPackagesRepository _repository;
  GetUpcomingPackagesUsecase(this._repository);

  @override
  Future<Either<Failure, List<PackageEntity>>> call(NoParams params) async {
    return _repository.getUpcomingPackages();
  }
}

class GetPastPackagesUsecase extends UseCase<List<PackageEntity>, NoParams> {
  final IPackagesRepository _repository;
  GetPastPackagesUsecase(this._repository);

  @override
  Future<Either<Failure, List<PackageEntity>>> call(NoParams params) async {
    return _repository.getPastPackages();
  }
}

class GetWishlistUsecase extends UseCase<List<PackageEntity>, NoParams> {
  final IPackagesRepository _repository;
  GetWishlistUsecase(this._repository);

  @override
  Future<Either<Failure, List<PackageEntity>>> call(NoParams params) async {
    return _repository.getWishlist();
  }
}

class ToggleWishlistParams extends Equatable {
  final String packageId;
  const ToggleWishlistParams({required this.packageId});

  @override
  List<Object?> get props => [packageId];
}

class ToggleWishlistUsecase extends UseCase<bool, ToggleWishlistParams> {
  final IPackagesRepository _repository;
  ToggleWishlistUsecase(this._repository);

  @override
  Future<Either<Failure, bool>> call(ToggleWishlistParams params) async {
    return _repository.toggleWishlist(params.packageId);
  }
}
