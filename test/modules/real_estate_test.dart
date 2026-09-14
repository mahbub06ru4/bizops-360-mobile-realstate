import 'package:bizops360_mobile/core/error/failure.dart';
import 'package:bizops360_mobile/data/repositories/fake_real_estate_project_repository.dart';
import 'package:bizops360_mobile/domain/entities/project_location.dart';
import 'package:bizops360_mobile/domain/entities/real_estate_project.dart';
import 'package:bizops360_mobile/modules/real_estate/projects/controllers/post_project_controller.dart';
import 'package:bizops360_mobile/modules/real_estate/projects/controllers/project_detail_controller.dart';
import 'package:bizops360_mobile/modules/real_estate/projects/controllers/projects_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('projects list loads the seeded demo projects', () async {
    final c = ProjectsController(FakeRealEstateProjectRepository());
    await c.load();
    expect(c.state.value.valueOrNull, isNotEmpty);
  });

  test('status filter narrows the visible list', () async {
    final c = ProjectsController(FakeRealEstateProjectRepository());
    await c.load();
    final total = c.visible.length;

    c.toggleStatus(ProjectStatus.draft);
    expect(c.visible.every((p) => p.status == ProjectStatus.draft), isTrue);
    expect(c.visible.length, lessThan(total));

    c.toggleStatus(ProjectStatus.draft); // clear
    expect(c.visible.length, total);
  });

  test(
    'submitForVerification fails a draft with no location, then succeeds once one is added',
    () async {
      final repo = FakeRealEstateProjectRepository();
      final created = await repo.create(
        title: 'New project',
        type: ProjectType.apartment,
      );
      final id = created.valueOrNull!.id;
      final detail = ProjectDetailController(
        repo,
        id,
        seed: created.valueOrNull,
      );
      await detail.reload();

      final blocked = await detail.submitForVerification();
      expect(blocked, isFalse);
      expect(detail.submitError.value, isNotNull);

      await repo.addLocation(
        id,
        location: const ProjectLocation(
          division: 'Dhaka',
          district: 'Dhaka',
          area: 'Banani',
        ),
      );
      await detail.reload();
      final ok = await detail.submitForVerification();
      expect(ok, isTrue);
      expect(detail.state.value.valueOrNull!.status, ProjectStatus.submitted);
    },
  );

  test('byId on a missing project yields NotFoundFailure', () async {
    final r = await FakeRealEstateProjectRepository().getById('nope');
    expect(r.failureOrNull, isA<NotFoundFailure>());
  });

  test('Post Project wizard: each step must be complete before advancing', () {
    final c = PostProjectController(FakeRealEstateProjectRepository());
    expect(c.canGoNext, isFalse); // no title yet
    c.title.value = 'Test project';
    expect(c.canGoNext, isTrue);
    c.next();
    expect(c.step.value, PostProjectStep.location);
  });

  test(
    'Post Project wizard: finish() plays the wizard back end-to-end',
    () async {
      final repo = FakeRealEstateProjectRepository();
      final c = PostProjectController(repo);
      c.title.value = 'Wizard Test Project';
      c.type.value = ProjectType.apartment;
      c.division.value = 'Dhaka';
      c.district.value = 'Dhaka';
      c.area.value = 'Banani';
      c.landSizeSqft.value = 5000;
      c.landCost.value = 20000000;
      c.buildingName.value = 'Tower 1';
      c.floors.value = 6;
      c.constructionCost.value = 50000000;
      c.unitNumber.value = 'B-1A';
      c.unitSizeSqft.value = 1200;
      c.unitPrice.value = 9000000;
      c.contactName.value = 'Test Seller';
      c.contactPhone.value = '+8801700000000';

      final project = await c.finish();

      expect(project, isNotNull);
      expect(project!.title, 'Wizard Test Project');
      expect(project.location?.area, 'Banani');
      expect(project.buildings, isNotEmpty);
      expect(project.buildings.first.units, isNotEmpty);
      expect(project.buildings.first.units.first.prices.first.amount, 9000000);
      expect(project.pricing?.landCost, 20000000);
      expect(project.contactName, 'Test Seller');

      // The project the fake repo now holds matches what finish() returned.
      final fetched = await repo.getById(project.id);
      expect(fetched.valueOrNull, project);
    },
  );
}
