/// Helpers for unwrapping the Laravel API response envelope.
///
/// A resource collection is `{ "data": [ ... ], "links": {...}, "meta": {...} }`
/// and a single resource is `{ "data": { ... } }`. Data sources call these so
/// the mappers only ever see the inner objects.
library;

/// The `data` array of a resource collection, as typed maps. Non-map entries and
/// a missing / non-list `data` yield an empty list rather than throwing.
List<Map<String, dynamic>> envelopeList(Map<String, dynamic>? body) {
  final data = body?['data'];
  if (data is! List) return const [];
  return data
      .whereType<Map<dynamic, dynamic>>()
      .map((e) => e.cast<String, dynamic>())
      .toList(growable: false);
}

/// The `data` object of a single-resource response. A missing / non-map `data`
/// yields an empty map.
Map<String, dynamic> envelopeObject(Map<String, dynamic>? body) {
  final data = body?['data'];
  return data is Map ? data.cast<String, dynamic>() : <String, dynamic>{};
}
