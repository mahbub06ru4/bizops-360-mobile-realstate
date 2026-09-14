import '../../core/error/result.dart';
import '../../domain/entities/installment.dart';
import '../../domain/entities/installment_plan.dart';
import '../../domain/entities/real_estate_booking.dart';
import '../../domain/repositories/real_estate_booking_repository.dart';
import '../datasources/real_estate_pipeline_remote_datasource.dart';
import '../models/real_estate_pipeline_mappers.dart';
import 'remote_guard.dart';

class RealEstateBookingRepositoryImpl implements RealEstateBookingRepository {
  RealEstateBookingRepositoryImpl(this._remote);

  final RealEstatePipelineRemoteDataSource _remote;

  @override
  Future<Result<List<RealEstateBooking>>> list({String? status}) {
    return guardRequest(
      () async => (await _remote.bookings(
        status: status,
      )).map(realEstateBookingFromJson).toList(growable: false),
    );
  }

  @override
  Future<Result<RealEstateBooking>> getById(String id) {
    return guardRequest(
      () async => realEstateBookingFromJson(await _remote.booking(id)),
    );
  }

  @override
  Future<Result<RealEstateBooking>> reserve({required String offerId}) {
    return guardRequest(
      () async =>
          realEstateBookingFromJson(await _remote.reserveBooking(offerId)),
    );
  }

  @override
  Future<Result<RealEstateBooking>> confirm(String bookingId) {
    return guardRequest(
      () async =>
          realEstateBookingFromJson(await _remote.confirmBooking(bookingId)),
    );
  }

  @override
  Future<Result<RealEstateBooking>> cancel(String bookingId) {
    return guardRequest(
      () async =>
          realEstateBookingFromJson(await _remote.cancelBooking(bookingId)),
    );
  }

  @override
  Future<Result<InstallmentPlan?>> planFor(String bookingId) {
    return guardRequest(() async {
      final json = await _remote.installmentPlan(bookingId);
      return json == null ? null : installmentPlanFromJson(json);
    });
  }

  @override
  Future<Result<InstallmentPlan>> createPlan(
    String bookingId, {
    required num downPaymentAmount,
    required int installmentCount,
    required InstallmentFrequency frequency,
    required DateTime startDate,
  }) {
    return guardRequest(() async {
      final body = <String, dynamic>{
        'down_payment_amount': downPaymentAmount,
        'installment_count': installmentCount,
        'frequency': installmentFrequencyToApi[frequency],
        'start_date':
            '${startDate.year.toString().padLeft(4, '0')}-'
            '${startDate.month.toString().padLeft(2, '0')}-'
            '${startDate.day.toString().padLeft(2, '0')}',
      };
      return installmentPlanFromJson(
        await _remote.createInstallmentPlan(bookingId, body),
      );
    });
  }

  @override
  Future<Result<List<Installment>>> installmentsFor(String planId) {
    return guardRequest(
      () async => (await _remote.installments(
        planId,
      )).map(installmentFromJson).toList(growable: false),
    );
  }

  @override
  Future<Result<Installment>> generateInvoice(String installmentId) {
    return guardRequest(
      () async =>
          installmentFromJson(await _remote.generateInvoice(installmentId)),
    );
  }

  @override
  Future<Result<Installment>> markPaid(String installmentId) {
    return guardRequest(
      () async =>
          installmentFromJson(await _remote.markInstallmentPaid(installmentId)),
    );
  }
}
