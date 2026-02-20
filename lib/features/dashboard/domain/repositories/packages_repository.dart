import 'package:dartz/dartz.dart';
import 'package:just_hike/core/error/failures.dart';
import 'package:just_hike/features/dashboard/domain/entities/package_entity.dart';

abstract class IPackagesRepository {
  Future<Either<Failure, List<PackageEntity>>> getAllPackages();
  Future<Either<Failure, List<PackageEntity>>> getUpcomingPackages();
  Future<Either<Failure, List<PackageEntity>>> getPastPackages();
  Future<Either<Failure, List<PackageEntity>>> getWishlist();
  Future<Either<Failure, PackageEntity>> getPackageById(String id);
  Future<Either<Failure, bool>> toggleWishlist(String packageId);
}
