import 'package:get/get.dart';

import '../../../../domain/entities/real_estate_booking.dart';
import '../../offers/bindings/offers_binding.dart';
import '../controllers/re_booking_detail_controller.dart';
import '../controllers/re_bookings_controller.dart';

class ReBookingsBinding extends Bindings {
  @override
  void dependencies() {
    ensureRealEstateBookingRepo();
    Get.lazyPut<ReBookingsController>(() => ReBookingsController(Get.find()));
  }
}

class ReBookingDetailBinding extends Bindings {
  @override
  void dependencies() {
    ensureRealEstateBookingRepo();
    final arg = Get.arguments;
    final seed = arg is RealEstateBooking ? arg : null;
    final id = seed?.id ?? (arg is String ? arg : '');
    Get.lazyPut<ReBookingDetailController>(
      () => ReBookingDetailController(Get.find(), id, seed: seed),
    );
  }
}
