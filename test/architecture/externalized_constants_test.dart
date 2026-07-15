import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final sourceFiles = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .where((file) => !file.path.endsWith('.g.dart'))
      .where((file) => !file.path.endsWith('.freezed.dart'))
      .toList();

  test('route paths are referenced through AppRoutes', () {
    final violations = _literalViolations(
      sourceFiles,
      ownerPath: 'lib/core/constants/app_routes.dart',
      literals: const ['/game', '/history'],
    );

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('persistence keys are referenced through AppStorageKeys', () {
    final violations = _literalViolations(
      sourceFiles,
      ownerPath: 'lib/core/constants/app_storage_keys.dart',
      literals: const ['game_records', 'app_settings'],
    );

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('presentation Text widgets use localized values', () {
    final rawTextPattern = RegExp(r'''(?:const\s+)?Text\(\s*['"][A-Za-z]''');
    final violations = sourceFiles
        .where((file) => file.path.contains('/presentation/'))
        .where((file) => rawTextPattern.hasMatch(file.readAsStringSync()))
        .map((file) => file.path)
        .toList();

    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}

List<String> _literalViolations(
  Iterable<File> files, {
  required String ownerPath,
  required List<String> literals,
}) {
  final violations = <String>[];
  for (final file in files.where((file) => file.path != ownerPath)) {
    final source = file.readAsStringSync();
    for (final literal in literals) {
      if (source.contains("'$literal'") || source.contains('"$literal"')) {
        violations.add('${file.path}: $literal');
      }
    }
  }
  return violations;
}
