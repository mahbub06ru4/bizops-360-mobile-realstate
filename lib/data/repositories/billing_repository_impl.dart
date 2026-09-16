import 'package:dio/dio.dart';

import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../core/network/dio_failure_mapper.dart';
import '../../domain/entities/billing_plan.dart';
import '../../domain/repositories/billing_repository.dart';
import '../datasources/billing_remote_datasource.dart';
import '../models/billing_mappers.dart';

class BillingRepositoryImpl implements BillingRepository {
  BillingRepositoryImpl(this._remote);

  final BillingRemoteDataSource _remote;

  @override
  Future<Result<List<BillingPlan>>> getPlans() => _guard(
    () async => (await _remote.plans()).map(billingPlanFromJson).toList(),
  );

  @override
  Future<Result<void>> selectPlan(String planCode) =>
      _guard(() => _remote.selectPlan(planCode));

  Future<Result<T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Result.ok(await run());
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    } on Object {
      return const Result.err(UnknownFailure());
    }
  }
}
