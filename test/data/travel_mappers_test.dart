import 'package:bizops360_mobile/core/network/api_envelope.dart';
import 'package:bizops360_mobile/data/models/travel_mappers.dart';
import 'package:bizops360_mobile/domain/entities/visa_application.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('envelope helpers', () {
    test('envelopeList pulls the data array, tolerating a missing key', () {
      expect(
        envelopeList(const {
          'data': [
            {'id': 1},
            {'id': 2},
          ],
        }),
        hasLength(2),
      );
      expect(envelopeList(const {}), isEmpty);
      expect(envelopeList(null), isEmpty);
    });

    test('envelopeObject pulls the data object', () {
      expect(
        envelopeObject(const {
          'data': {'id': 9},
        })['id'],
        9,
      );
      expect(envelopeObject(const {'data': 'nope'}), isEmpty);
    });
  });

  group('travellerFromJson', () {
    test('maps the traveller resource', () {
      final t = travellerFromJson(const {
        'id': 1,
        'full_name': 'Rahim Uddin',
        'nationality': 'Bangladeshi',
        'phone': '+8801711000000',
        'email': 'rahim@wanderlust.test',
        'date_of_birth': '1988-04-12',
        'passport_number': 'BD0123456',
        'passport_expiry': '2030-09-09',
      });

      expect(t.id, '1');
      expect(t.name, 'Rahim Uddin');
      expect(t.passportNumber, 'BD0123456');
      expect(t.dateOfBirth, DateTime(1988, 4, 12));
      expect(t.passportExpiry, DateTime(2030, 9, 9));
    });

    test('tolerates null optional fields', () {
      final t = travellerFromJson(const {
        'id': 4,
        'full_name': 'No Passport',
        'nationality': 'Bangladeshi',
        'phone': null,
        'date_of_birth': null,
        'passport_expiry': null,
      });
      expect(t.phone, isNull);
      expect(t.passportExpiry, isNull);
    });
  });

  group('visaApplicationFromJson', () {
    final sample = {
      'id': 1,
      'destination_country': 'Thailand',
      'visa_type': 'tourist',
      'stage': 'documents_pending',
      'submitted_on': null,
      'decision_on': null,
      'traveller': {'full_name': 'Rahim Uddin'},
      'requirements': [
        {'id': 1, 'name': 'Passport', 'collected': true},
        {'id': 2, 'name': 'Photograph', 'collected': true},
        {'id': 3, 'name': 'Bank statement', 'collected': false},
      ],
    };

    test('maps stage, traveller name and requirement checklist', () {
      final v = visaApplicationFromJson(sample);
      expect(v.id, '1');
      expect(v.travellerName, 'Rahim Uddin');
      expect(v.country, 'Thailand');
      expect(v.stage, VisaStage.docsRequired);
      expect(v.docs, hasLength(3));
      expect(v.docsCollected, 2);
      expect(v.allDocsCollected, isFalse);
    });

    test('cancelled collapses onto rejected', () {
      final v = visaApplicationFromJson({...sample, 'stage': 'cancelled'});
      expect(v.stage, VisaStage.rejected);
    });

    test('requirement lookup by name', () {
      expect(requirementIdByName(sample, 'Bank statement'), '3');
      expect(requirementCollected(sample, 'Passport'), isTrue);
      expect(requirementCollected(sample, 'Bank statement'), isFalse);
      expect(requirementIdByName(sample, 'Nonexistent'), isNull);
    });
  });
}
