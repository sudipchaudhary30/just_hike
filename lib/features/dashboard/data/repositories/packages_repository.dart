import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_hike/core/error/failures.dart';
import 'package:just_hike/core/services/connectivity/networkinfo.dart';
import 'package:just_hike/features/dashboard/data/datasources/remote/packages_remote_datasource.dart';
import 'package:just_hike/features/dashboard/domain/entities/package_entity.dart';
import 'package:just_hike/features/dashboard/domain/repositories/packages_repository.dart';

final packagesRepositoryProvider = Provider<IPackagesRepository>((ref) {
  final remoteDataSource = ref.read(packagesRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);

  return PackagesRepository(
    remoteDataSource: remoteDataSource,
    networkInfo: networkInfo,
  );
});

class PackagesRepository implements IPackagesRepository {
  final IPackagesRemoteDatasource _remoteDataSource;
  final NetworkInfo _networkInfo;

  PackagesRepository({
    required IPackagesRemoteDatasource remoteDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<PackageEntity>>> getAllPackages() async {
    if (await _networkInfo.isConnected) {
      try {
        final packages = await _remoteDataSource.getAllPackages();
        return Right(packages.map((model) => model.toEntity()).toList());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to fetch packages',
            statuscode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<PackageEntity>>> getUpcomingPackages() async {
    if (await _networkInfo.isConnected) {
      try {
        final packages = await _remoteDataSource.getUpcomingPackages();
        return Right(packages.map((model) => model.toEntity()).toList());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to fetch packages',
            statuscode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<PackageEntity>>> getPastPackages() async {
    if (await _networkInfo.isConnected) {
      try {
        final packages = await _remoteDataSource.getPastPackages();
        return Right(packages.map((model) => model.toEntity()).toList());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to fetch packages',
            statuscode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<PackageEntity>>> getWishlist() async {
    if (await _networkInfo.isConnected) {
      try {
        final packages = await _remoteDataSource.getWishlist();
        return Right(packages.map((model) => model.toEntity()).toList());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to fetch wishlist',
            statuscode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, PackageEntity>> getPackageById(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        final package = await _remoteDataSource.getPackageById(id);
        return Right(package.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to fetch package',
            statuscode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleWishlist(String packageId) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.toggleWishlist(packageId);
        return Right(result);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to update wishlist',
            statuscode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }
}
