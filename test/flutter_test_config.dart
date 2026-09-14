import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

/// Runs once before any test file. Stops `google_fonts` from attempting a
/// network fetch in CI — it falls back to the bundled font silently.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  await testMain();
}
