@Tags(['integration'])
library;

import 'package:bizops360_mobile/core/network/api_client.dart';
import 'package:bizops360_mobile/data/datasources/traveller_remote_datasource.dart';
import 'package:bizops360_mobile/data/datasources/visa_remote_datasource.dart';
import 'package:bizops360_mobile/data/repositories/traveller_repository_impl.dart';
import 'package:bizops360_mobile/data/repositories/visa_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// End-to-end check of the HTTP-backed travel repositories against a running
/// `bizops360-api` (default `http://localhost`, override with `API_ORIGIN`).
/// Excluded from the default run — see `dart_test.yaml`.
///
///   flutter test --tags integration
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
    final token = login.data!['token'] as String;
    client = ApiClient(
      Dio(
        BaseOptions(
          baseUrl: root,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      ),
    );
  });

  test('TravellerRepositoryImpl lists and fetches seeded travellers', () async {
    final repo = TravellerRepositoryImpl(TravellerRemoteDataSource(client));

    final list = await repo.travellers();
    expect(list.isOk, isTrue, reason: list.failureOrNull?.message);
    final travellers = list.valueOrNull!;
    expect(travellers, isNotEmpty);

    final one = await repo.byId(travellers.first.id);
    expect(one.isOk, isTrue);
    expect(one.valueOrNull!.name, travellers.first.name);
  });

  test(
    'VisaRepositoryImpl lists applications and toggles a requirement',
    () async {
      final repo = VisaRepositoryImpl(VisaRemoteDataSource(client));

      final list = await repo.applications();
      expect(list.isOk, isTrue, reason: list.failureOrNull?.message);
      final apps = list.valueOrNull!;
      expect(apps, isNotEmpty);

      final target = apps.first;
      final doc = target.docs.first.name;
      final before = target.docs.first.collected;

      final toggled = await repo.toggleDoc(target.id, doc);
      expect(toggled.isOk, isTrue, reason: toggled.failureOrNull?.message);
      final afterDoc = toggled.valueOrNull!.docs.firstWhere(
        (d) => d.name == doc,
      );
      expect(afterDoc.collected, !before);

      // restore original state
      await repo.toggleDoc(target.id, doc);
    },
  );
}
