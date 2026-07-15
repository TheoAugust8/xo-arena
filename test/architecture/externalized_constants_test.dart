import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps routes, persistence keys, and UI copy in dedicated files', () {
    expect(File('lib/core/constants/app_routes.dart').existsSync(), isTrue);
    expect(
      File('lib/core/constants/app_storage_keys.dart').existsSync(),
      isTrue,
    );
    expect(File('lib/l10n/app_en.arb').existsSync(), isTrue);
  });
}
