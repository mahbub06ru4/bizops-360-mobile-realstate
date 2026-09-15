import 'package:bizops360_mobile/data/repositories/fake_buyer_repository.dart';
import 'package:bizops360_mobile/data/repositories/fake_real_estate_project_repository.dart';
import 'package:bizops360_mobile/domain/entities/real_estate_project.dart';
import 'package:bizops360_mobile/modules/real_estate/buyer/browse/controllers/browse_controller.dart';
import 'package:bizops360_mobile/modules/real_estate/buyer/my_properties/controllers/my_properties_controller.dart';
import 'package:bizops360_mobile/modules/real_estate/buyer/saved/controllers/saved_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BrowseController', () {
    test('only verified projects are returned', () async {
      final projects = FakeRealEstateProjectRepository();
      final buyer = FakeBuyerRepository(projects);
      final c = BrowseController(buyer);
      await c.load();

      final visible = c.state.value.valueOrNull!;
      expect(visible, isNotEmpty);
      expect(visible.every((p) => p.status == ProjectStatus.verified), isTrue);
      // The seeded catalogue also has a submitted and a draft project — they
      // must never surface to a buyer.
      expect(visible.any((p) => p.status != ProjectStatus.verified), isFalse);
    });

    test('location/landmark keyword search narrows the list', () async {
      final projects = FakeRealEstateProjectRepository();
      final buyer = FakeBuyerRepository(projects);
      final c = BrowseController(buyer);
      await c.load();
      final total = c.state.value.valueOrNull!.length;

      await c.search('Uttara');
      expect(c.state.value.valueOrNull, isNotEmpty);
      expect(
        c.state.value.valueOrNull!.every(
          (p) =>
              (p.location?.area.toLowerCase().contains('uttara') ?? false) ||
              p.title.toLowerCase().contains('uttara'),
        ),
        isTrue,
      );

      await c.search('no-such-place-xyz');
      expect(c.state.value.valueOrNull, isEmpty);

      await c.search('');
      expect(c.state.value.valueOrNull!.length, total);
    });

    test('toggleSave adds then removes a saved id', () async {
      final projects = FakeRealEstateProjectRepository();
      final buyer = FakeBuyerRepository(projects);
      final c = BrowseController(buyer);
      await c.load();
      final id = c.state.value.valueOrNull!.first.id;

      expect(c.isSaved(id), isFalse);
      await c.toggleSave(id);
      expect(c.isSaved(id), isTrue);
      await c.toggleSave(id);
      expect(c.isSaved(id), isFalse);
    });
  });

  group('SavedController compare selection', () {
    test('toggleCompare caps the selection at 3', () async {
      final projects = FakeRealEstateProjectRepository();
      final buyer = FakeBuyerRepository(projects);
      final c = SavedController(buyer, projects);

      expect(c.toggleCompare('a'), isTrue);
      expect(c.toggleCompare('b'), isTrue);
      expect(c.toggleCompare('c'), isTrue);
      expect(c.toggleCompare('d'), isFalse);
      expect(c.selectedForCompare, ['a', 'b', 'c']);

      // Toggling an already-selected id removes it, freeing a slot.
      expect(c.toggleCompare('b'), isTrue);
      expect(c.selectedForCompare, ['a', 'c']);
      expect(c.toggleCompare('d'), isTrue);
      expect(c.selectedForCompare, ['a', 'c', 'd']);
    });

    test('canCompare requires at least 2 selections', () {
      final projects = FakeRealEstateProjectRepository();
      final buyer = FakeBuyerRepository(projects);
      final c = SavedController(buyer, projects);

      expect(c.canCompare, isFalse);
      c.toggleCompare('a');
      expect(c.canCompare, isFalse);
      c.toggleCompare('b');
      expect(c.canCompare, isTrue);
    });

    test('saved list only includes saved ids, and unsave removes it', () async {
      final projects = FakeRealEstateProjectRepository();
      final buyer = FakeBuyerRepository(projects);
      final verified = (await buyer.browseVerified()).valueOrNull!.first;
      await buyer.saveProject(verified.id);

      final c = SavedController(buyer, projects);
      await c.load();
      expect(c.state.value.valueOrNull!.map((p) => p.id), [verified.id]);

      await c.unsave(verified.id);
      expect(c.state.value.valueOrNull, isEmpty);
    });
  });

  group('MyPropertiesController / paid-remaining-next-due', () {
    test('the seeded demo booking reports paid/remaining/next due', () async {
      final projects = FakeRealEstateProjectRepository();
      final buyer = FakeBuyerRepository(projects);
      final c = MyPropertiesController(buyer);
      await c.load();

      final rows = c.state.value.valueOrNull!;
      expect(rows, hasLength(1));
      final row = rows.first;
      expect(row.plan, isNotNull);
      expect(row.paidAmount, greaterThan(0));
      expect(row.remainingAmount, row.booking.agreedPrice - row.paidAmount);
      expect(row.nextDue, isNotNull);
      expect(row.nextDue!.dueDate.isAfter(DateTime(2000)), isTrue);
    });
  });
}
