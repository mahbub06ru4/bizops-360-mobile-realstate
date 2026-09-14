import 'package:bizops360_mobile/core/error/failure.dart';
import 'package:bizops360_mobile/data/repositories/fake_invoice_repository.dart';
import 'package:bizops360_mobile/data/repositories/fake_offer_repository.dart';
import 'package:bizops360_mobile/data/repositories/fake_property_requirement_repository.dart';
import 'package:bizops360_mobile/data/repositories/fake_real_estate_booking_repository.dart';
import 'package:bizops360_mobile/domain/entities/installment.dart';
import 'package:bizops360_mobile/domain/entities/installment_plan.dart';
import 'package:bizops360_mobile/domain/entities/offer.dart';
import 'package:bizops360_mobile/domain/entities/real_estate_booking.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Requirement -> match flow', () {
    test(
      'creating a requirement then matching returns scored matches',
      () async {
        final repo = FakePropertyRequirementRepository();
        final created = await repo.create(
          leadId: 'c9',
          leadName: 'Test Lead',
          budgetMin: 10000000,
          budgetMax: 16000000,
          preferredLocations: 'Chattogram',
        );
        final requirement = created.valueOrNull!;
        expect(requirement.leadId, 'c9');

        final matched = await repo.match(requirement.id);
        final matches = matched.valueOrNull!;
        expect(matches, isNotEmpty);
        // Sorted best-first.
        for (var i = 1; i < matches.length; i++) {
          expect(
            matches[i - 1].matchScore,
            greaterThanOrEqualTo(matches[i].matchScore),
          );
        }

        final refetched = await repo.matchesFor(requirement.id);
        expect(refetched.valueOrNull, matches);
      },
    );

    test('matching an unknown requirement id fails', () async {
      final repo = FakePropertyRequirementRepository();
      final result = await repo.match('nope');
      expect(result.failureOrNull, isA<NotFoundFailure>());
    });
  });

  group('Offer negotiation chain', () {
    test(
      'counter then accept transitions the thread head to accepted',
      () async {
        final repo = FakeOfferRepository();
        final opening = await repo.makeOffer(
          leadId: 'c9',
          leadName: 'Test Lead',
          unitId: 'uX',
          unitName: 'Unit X',
          projectId: 'rpX',
          projectTitle: 'Test Project',
          offeredPrice: 1000000,
          offeredBy: OfferParty.seller,
        );
        final head0 = opening.valueOrNull!;
        expect(head0.status, OfferStatus.pending);

        final countered = await repo.counter(
          head0.id,
          offeredPrice: 900000,
          offeredBy: OfferParty.buyer,
        );
        final head1 = countered.valueOrNull!;
        expect(head1.status, OfferStatus.countered);
        expect(head1.previousOfferId, head0.id);

        final accepted = await repo.accept(head1.id);
        final head2 = accepted.valueOrNull!;
        expect(head2.status, OfferStatus.accepted);

        // `accept`/`reject` mutate the offer's status in place (same id),
        // so head2.id == head1.id — the chain has two distinct nodes.
        expect(head2.id, head1.id);
        final history = (await repo.history(head2.id)).valueOrNull!;
        expect(history.map((o) => o.id), [head0.id, head1.id]);

        final latest = (await repo.latestPerThread()).valueOrNull!;
        expect(latest.any((o) => o.id == head2.id), isTrue);
      },
    );

    test('countering an already-accepted offer fails', () async {
      final repo = FakeOfferRepository();
      // Seeded thread o1 -> o2 -> o3(accepted).
      final result = await repo.counter(
        'o3',
        offeredPrice: 1,
        offeredBy: OfferParty.buyer,
      );
      expect(result.isErr, isTrue);
    });
  });

  group('Installment plan generation math', () {
    test('splits evenly when the amount divides exactly', () {
      final amounts = splitInstallmentAmounts(12000, 6);
      expect(amounts, [2000, 2000, 2000, 2000, 2000, 2000]);
      expect(amounts.fold<num>(0, (a, b) => a + b), 12000);
    });

    test('the last installment absorbs the rounding remainder', () {
      final amounts = splitInstallmentAmounts(11040000, 7);
      expect(amounts.length, 7);
      final sum = amounts.fold<num>(0, (a, b) => a + b);
      expect(sum, 11040000);
      // Every installment but the last is the same rounded amount.
      for (var i = 0; i < amounts.length - 1; i++) {
        expect(amounts[i], amounts[0]);
      }
      expect(amounts.last, isNot(amounts.first));
    });

    test('a single installment gets the full amount', () {
      expect(splitInstallmentAmounts(5000, 1), [5000]);
    });

    test(
      'createPlan on a booking builds a schedule whose amounts sum to the financed total',
      () async {
        final offers = FakeOfferRepository();
        final invoices = FakeInvoiceRepository();
        final bookings = FakeRealEstateBookingRepository(offers, invoices);

        // Seeded booking `bk1`: agreed price 13,800,000, already booked.
        final plan = await bookings.createPlan(
          'bk1',
          downPaymentAmount: 3450000, // 25%
          installmentCount: 4,
          frequency: InstallmentFrequency.monthly,
          startDate: DateTime(2026),
        );
        // A plan already exists in the seed data for bk1, so this should fail —
        // exercise the guard, then use a fresh reservation instead.
        expect(plan.isErr, isTrue);

        final reserved = await bookings.reserve(offerId: 'o3');
        final booking = reserved.valueOrNull!;
        expect(booking.status, RealEstateBookingStatus.reserved);

        // The backend requires a booking to be `booked` (or `completed`)
        // before an installment plan can be created.
        final tooEarly = await bookings.createPlan(
          booking.id,
          downPaymentAmount: booking.agreedPrice * 0.25,
          installmentCount: 4,
          frequency: InstallmentFrequency.monthly,
          startDate: DateTime(2026),
        );
        expect(tooEarly.isErr, isTrue);

        final confirmed = await bookings.confirm(booking.id);
        final bookedBooking = confirmed.valueOrNull!;
        expect(bookedBooking.status, RealEstateBookingStatus.booked);

        final downPayment = bookedBooking.agreedPrice * 0.25;
        final created = await bookings.createPlan(
          bookedBooking.id,
          downPaymentAmount: downPayment,
          installmentCount: 4,
          frequency: InstallmentFrequency.monthly,
          startDate: DateTime(2026),
        );
        final newPlan = created.valueOrNull!;
        expect(newPlan.downPaymentAmount, downPayment);
        expect(newPlan.installments, hasLength(4));

        final installments = (await bookings.installmentsFor(
          newPlan.id,
        )).valueOrNull!;
        expect(installments, hasLength(4));
        final total = installments.fold<num>(0, (a, i) => a + i.amount);
        expect(total, closeTo(bookedBooking.agreedPrice - downPayment, 0.01));
        expect(
          installments.every((i) => i.status == InstallmentStatus.pending),
          isTrue,
        );
      },
    );

    test(
      'generateInvoice raises a Finance invoice and links it back',
      () async {
        final offers = FakeOfferRepository();
        final invoices = FakeInvoiceRepository();
        final bookings = FakeRealEstateBookingRepository(offers, invoices);

        // Seeded installment `inst4` on plan1/bk1 is pending.
        final result = await bookings.generateInvoice('inst4');
        final installment = result.valueOrNull!;
        expect(installment.status, InstallmentStatus.invoiced);
        expect(installment.invoiceId, isNotNull);

        final invoice = (await invoices.byId(
          installment.invoiceId!,
        )).valueOrNull!;
        expect(invoice.amount, installment.amount);
      },
    );

    test('markPaid settles the installment (and its linked invoice)', () async {
      final offers = FakeOfferRepository();
      final invoices = FakeInvoiceRepository();
      final bookings = FakeRealEstateBookingRepository(offers, invoices);

      final generated = await bookings.generateInvoice('inst5');
      final invoiceId = generated.valueOrNull!.invoiceId!;

      final paid = await bookings.markPaid('inst5');
      expect(paid.valueOrNull!.status, InstallmentStatus.paid);

      final invoice = (await invoices.byId(invoiceId)).valueOrNull!;
      expect(invoice.paidAmount, generated.valueOrNull!.amount);
    });
  });
}
