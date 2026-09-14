import 'package:get/get.dart';

import '../../../../data/datasources/real_estate_pipeline_remote_datasource.dart';
import '../../../../data/repositories/fake_offer_repository.dart';
import '../../../../data/repositories/fake_real_estate_booking_repository.dart';
import '../../../../data/repositories/offer_repository_impl.dart';
import '../../../../data/repositories/real_estate_booking_repository_impl.dart';
import '../../../../data/repositories/repo_registry.dart';
import '../../../../domain/repositories/offer_repository.dart';
import '../../../../domain/repositories/real_estate_booking_repository.dart';
import '../../../../presentation/crm/bindings/crm_bindings.dart';
import '../../../../presentation/finance/bindings/finance_bindings.dart';
import '../controllers/new_offer_controller.dart';
import '../controllers/offer_thread_controller.dart';
import '../controllers/offers_controller.dart';

void ensureOfferRepo() => registerRepo<OfferRepository>(
  (client) => OfferRepositoryImpl(RealEstatePipelineRemoteDataSource(client)),
  FakeOfferRepository.new,
);

/// Booking repo lives here too since reserving one is an offer-thread action
/// (`OfferThreadController.reserveBooking`) — see `re_bookings/` for the
/// standalone booking-list/detail binding.
void ensureRealEstateBookingRepo() {
  // The fake booking repo looks up an accepted offer's terms and raises
  // invoices through these two, so both must already be registered.
  ensureOfferRepo();
  ensureInvoiceRepo();
  registerRepo<RealEstateBookingRepository>(
    (client) => RealEstateBookingRepositoryImpl(
      RealEstatePipelineRemoteDataSource(client),
    ),
    () => FakeRealEstateBookingRepository(Get.find(), Get.find()),
  );
}

class OffersBinding extends Bindings {
  @override
  void dependencies() {
    ensureOfferRepo();
    Get.lazyPut<OffersController>(() => OffersController(Get.find()));
  }
}

class OfferThreadBinding extends Bindings {
  @override
  void dependencies() {
    ensureOfferRepo();
    ensureRealEstateBookingRepo();
    final id = Get.arguments is String ? Get.arguments as String : '';
    Get.lazyPut<OfferThreadController>(
      () => OfferThreadController(Get.find(), Get.find(), id),
    );
  }
}

/// Argument shape for the "make offer" route: a small record carrying the
/// project/unit the offer is against (from a project's unit list action).
typedef NewOfferArgs = ({
  String projectId,
  String projectTitle,
  String unitId,
  String unitName,
});

class NewOfferBinding extends Bindings {
  @override
  void dependencies() {
    ensureOfferRepo();
    ensureCrmRepo();
    final arg = Get.arguments;
    final args = arg is NewOfferArgs
        ? arg
        : (projectId: '', projectTitle: '', unitId: '', unitName: '');
    Get.lazyPut<NewOfferController>(
      () => NewOfferController(
        Get.find(),
        projectId: args.projectId,
        projectTitle: args.projectTitle,
        unitId: args.unitId,
        unitName: args.unitName,
      ),
    );
  }
}
