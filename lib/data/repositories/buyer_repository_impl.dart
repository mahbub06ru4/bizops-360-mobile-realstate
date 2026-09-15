import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../domain/entities/installment_plan.dart';
import '../../domain/entities/real_estate_booking.dart';
import '../../domain/entities/real_estate_project.dart';
import '../../domain/repositories/buyer_repository.dart';
import '../datasources/buyer_remote_datasource.dart';
import '../models/real_estate_mappers.dart';
import '../models/real_estate_pipeline_mappers.dart';
import 'remote_guard.dart';

class BuyerRepositoryImpl implements BuyerRepository {
  BuyerRepositoryImpl(this._remote);

  final BuyerRemoteDataSource _remote;

  @override
  Future<Result<List<RealEstateProject>>> browseVerified({String? query}) {
    return guardRequest(
      () async => (await _remote.browseVerified(
        query: query,
      )).map(realEstateProjectFromJson).toList(growable: false),
    );
  }

  @override
  Future<Result<List<String>>> savedProjectIds() {
    return guardRequest(
      () async => (await _remote.savedProjects())
          .map((json) => (json['project_id'] ?? json['id']).toString())
          .toList(growable: false),
    );
  }

  @override
  Future<Result<void>> saveProject(String projectId) {
    return guardRequest(() => _remote.saveProject(projectId));
  }

  @override
  Future<Result<void>> unsaveProject(String projectId) {
    return guardRequest(() => _remote.unsaveProject(projectId));
  }

  @override
  Future<Result<List<RealEstateBooking>>> myBookings() {
    return guardRequest(
      () async => (await _remote.myBookings())
          .map(realEstateBookingFromJson)
          .toList(growable: false),
    );
  }

  @override
  Future<Result<InstallmentPlan>> installmentPlanFor(String bookingId) async {
    final result = await guardRequest(() => _remote.booking(bookingId));
    return result.fold((json) {
      final plan = json['installment_plan'];
      if (plan is! Map<String, dynamic>) {
        return const Result.err(NotFoundFailure());
      }
      return Result.ok(installmentPlanFromJson(plan));
    }, Result.err);
  }
}
