@Tags(['integration'])
library;

import 'package:bizops360_mobile/core/network/api_client.dart';
import 'package:bizops360_mobile/data/datasources/booking_remote_datasource.dart';
import 'package:bizops360_mobile/data/datasources/crm_remote_datasource.dart';
import 'package:bizops360_mobile/data/datasources/notification_remote_datasource.dart';
import 'package:bizops360_mobile/data/datasources/report_remote_datasource.dart';
import 'package:bizops360_mobile/data/datasources/task_remote_datasource.dart';
import 'package:bizops360_mobile/data/repositories/booking_repository_impl.dart';
import 'package:bizops360_mobile/data/repositories/crm_repository_impl.dart';
import 'package:bizops360_mobile/data/repositories/notification_repository_impl.dart';
import 'package:bizops360_mobile/data/repositories/report_repository_impl.dart';
import 'package:bizops360_mobile/data/repositories/task_repository_impl.dart';
import 'package:bizops360_mobile/domain/entities/task_item.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// End-to-end checks for the module repositories against a running
/// `bizops360-api`. Excluded from the default run — see `dart_test.yaml`.
///
///   flutter test --tags integration --run-skipped
void main() {
  const origin = String.fromEnvironment(
    'API_ORIGIN',
    defaultValue: 'http://localhost',
  );
  const root = '$origin/api/v1';
  late ApiClient client;

  setUpAll(() async {
    final login = await Dio().post<Map<String, dynamic>>(
      '$root/auth/login',
      data: const {'email': 'manager@wanderlust.test', 'password': 'password'},
      options: Options(headers: const {'Accept': 'application/json'}),
    );
    client = ApiClient(
      Dio(
        BaseOptions(
          baseUrl: root,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${login.data!['token']}',
          },
        ),
      ),
    );
  });

  test('notifications list', () async {
    final r = await NotificationRepositoryImpl(
      NotificationRemoteDataSource(client),
    ).list();
    expect(r.isOk, isTrue, reason: r.failureOrNull?.message);
  });

  test('tasks: create → list → status', () async {
    final repo = TaskRepositoryImpl(TaskRemoteDataSource(client));

    final created = await repo.create(
      title: 'Integration test task',
      priority: TaskPriority.high,
    );
    expect(created.isOk, isTrue, reason: created.failureOrNull?.message);
    final id = created.valueOrNull!.id;

    final list = await repo.myTasks();
    expect(list.valueOrNull!.any((t) => t.id == id), isTrue);

    final moved = await repo.updateStatus(id, TaskStatus.inProgress);
    expect(moved.valueOrNull!.status, TaskStatus.inProgress);
  });

  test('crm: customers + follow-ups', () async {
    final repo = CrmRepositoryImpl(CrmRemoteDataSource(client));
    final customers = await repo.customers();
    expect(customers.isOk, isTrue, reason: customers.failureOrNull?.message);
    if (customers.valueOrNull!.isNotEmpty) {
      final history = await repo.history(customers.valueOrNull!.first.id);
      expect(history.isOk, isTrue);
    }
    expect((await repo.followUps()).isOk, isTrue);
  });

  test('bookings list + detail', () async {
    final repo = BookingRepositoryImpl(BookingRemoteDataSource(client));
    final list = await repo.bookings();
    expect(list.isOk, isTrue, reason: list.failureOrNull?.message);
    if (list.valueOrNull!.isNotEmpty) {
      final one = await repo.byId(list.valueOrNull!.first.id);
      expect(one.isOk, isTrue);
    }
    expect((await repo.departures()).isOk, isTrue);
  });

  test('reports overview composes the module dashboards', () async {
    final r = await ReportRepositoryImpl(
      ReportRemoteDataSource(client),
    ).overview();
    expect(r.isOk, isTrue, reason: r.failureOrNull?.message);
    expect(r.valueOrNull!.monthlyRevenue, isNotEmpty);
  });
}
