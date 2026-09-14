import '../../core/error/result.dart';
import '../entities/traveller.dart';

abstract interface class TravellerRepository {
  Future<Result<List<Traveller>>> travellers();

  Future<Result<Traveller>> byId(String id);

  Future<Result<List<TravelHistoryEntry>>> history(String id);

  /// Create a traveller. Only [name] is required; the rest are optional.
  Future<Result<Traveller>> create({
    required String name,
    String? nationality,
    String? phone,
    String? passportNumber,
    DateTime? passportExpiry,
  });
}
