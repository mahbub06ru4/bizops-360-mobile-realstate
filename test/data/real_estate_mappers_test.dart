import 'package:bizops360_mobile/data/models/real_estate_mappers.dart';
import 'package:bizops360_mobile/domain/entities/real_estate_project.dart';
import 'package:bizops360_mobile/domain/entities/unit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('realEstateProjectFromJson', () {
    test('maps type, status, location, buildings, units and pricing', () {
      final json = {
        'id': 1,
        'title': 'Diabari Green Residency',
        'type': 'land_share',
        'status': 'verified',
        'description': 'A land-share project.',
        'location': {
          'division': 'Dhaka',
          'district': 'Dhaka',
          'area': 'Uttara',
          'sector': 'Sector 18',
          'landmarks': ['Diabari Metro Station'],
        },
        'buildings': [
          {
            'id': 10,
            'name': 'Land parcel',
            'floors': 1,
            'units': [
              {
                'id': 20,
                'building_id': 10,
                'unit_number': 'Share #1',
                'size_sqft': 720,
                'status': 'available',
                'facing': 'south',
                'prices': [
                  {'id': 30, 'label': 'Per katha', 'amount': '3200000.00'},
                ],
                'media': [
                  {'id': 40, 'url': 'https://x.test/a.jpg', 'is_primary': true},
                ],
              },
            ],
          },
        ],
        'amenities': [
          {'id': 50, 'name': 'Boundary wall', 'icon': 'security'},
        ],
        'pricing': {
          'land_cost': 32000000,
          'construction_cost': 0,
          'consultancy_cost': 600000,
        },
        'payment_plans': [
          {
            'id': 60,
            'name': 'Standard',
            'down_payment_percent': 30,
            'installment_count': 12,
          },
        ],
        'contact_name': 'Rafiqul Islam',
        'contact_phone': '+8801711223344',
        'created_at': '2026-08-01T00:00:00+00:00',
      };

      final p = realEstateProjectFromJson(json);

      expect(p.id, '1');
      expect(p.title, 'Diabari Green Residency');
      expect(p.type, ProjectType.landShare);
      expect(p.status, ProjectStatus.verified);
      expect(p.location?.division, 'Dhaka');
      expect(p.location?.landmarks, ['Diabari Metro Station']);
      expect(p.buildings, hasLength(1));
      expect(p.buildings.first.units, hasLength(1));
      final unit = p.buildings.first.units.first;
      expect(unit.buildingId, '10');
      expect(unit.unitNumber, 'Share #1');
      expect(unit.facing, UnitFacing.south);
      expect(unit.sizeSqft, 720);
      expect(unit.prices.first.amount, 3200000);
      expect(unit.media.first.isPrimary, isTrue);
      expect(p.amenities.first.name, 'Boundary wall');
      expect(p.pricing?.estimatedTotal, 32600000);
      expect(p.paymentPlans.first.installmentCount, 12);
      expect(p.contactName, 'Rafiqul Islam');
      expect(p.canSubmit, isFalse); // already verified, not a draft
    });

    test('an incomplete draft has sensible fallbacks', () {
      final p = realEstateProjectFromJson(const {
        'id': 2,
        'title': 'Konabari Plaza',
        'type': 'commercial',
        'status': 'draft',
      });

      expect(p.type, ProjectType.commercial);
      expect(p.status, ProjectStatus.draft);
      expect(p.location, isNull);
      expect(p.buildings, isEmpty);
      expect(p.unitCount, 0);
      expect(p.canSubmit, isFalse); // no location yet
    });
  });

  group('projectLocationToJson / round-trip', () {
    test('round-trips through from/to json', () {
      final json = realEstateProjectFromJson(const {
        'id': 3,
        'title': 'X',
        'type': 'apartment',
        'status': 'draft',
        'location': {
          'division': 'Chattogram',
          'district': 'Chattogram',
          'area': 'Khulshi',
        },
      });
      final backToJson = projectLocationToJson(json.location!);
      expect(backToJson['division'], 'Chattogram');
      expect(backToJson['area'], 'Khulshi');
    });
  });
}
