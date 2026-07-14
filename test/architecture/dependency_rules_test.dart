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

  test('domain stays independent from frameworks', () {
    const forbiddenPackages = [
      'package:flutter/',
      'package:flutter_riverpod/',
      'package:go_router/',
      'package:riverpod_annotation/',
      'package:shared_preferences/',
      'package:audioplayers/',
    ];

    final violations = _violations(
      sourceFiles.where((file) => file.path.contains('/domain/')),
      (importPath, _) => forbiddenPackages.any(importPath.startsWith),
    );

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('presentation never imports data implementations', () {
    final violations = _violations(
      sourceFiles.where((file) => file.path.contains('/presentation/')),
      (importPath, _) => importPath.contains('/data/'),
    );

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('data never imports presentation', () {
    final violations = _violations(
      sourceFiles.where((file) => file.path.contains('/data/')),
      (importPath, _) => importPath.contains('/presentation/'),
    );

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('features and shared modules never import app', () {
    final violations = _violations(
      sourceFiles.where(
        (file) =>
            file.path.contains('/features/') || file.path.contains('/shared/'),
      ),
      (importPath, _) => importPath.startsWith('package:xo_arena/app/'),
    );

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('core stays independent from product modules', () {
    final violations = _violations(
      sourceFiles.where((file) => file.path.contains('/core/')),
      (importPath, _) =>
          importPath.startsWith('package:xo_arena/app/') ||
          importPath.startsWith('package:xo_arena/features/') ||
          importPath.startsWith('package:xo_arena/shared/'),
    );

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('feature presentation never imports another feature presentation', () {
    final violations = _violations(
      sourceFiles.where(
        (file) =>
            file.path.contains('/features/') &&
            file.path.contains('/presentation/'),
      ),
      (importPath, sourcePath) {
        final sourceFeature = _featureName(sourcePath);
        final importedFeature = RegExp(
          r'^package:xo_arena/features/([^/]+)/presentation/',
        ).firstMatch(importPath)?.group(1);
        return importedFeature != null && importedFeature != sourceFeature;
      },
    );

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('use cases live inside domain layer', () {
    final violations = sourceFiles
        .map((file) => file.path)
        .where((path) => path.contains('/usecases/'))
        .where((path) => !path.contains('/domain/usecases/'))
        .toList();

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('domain sources live inside responsibility folders', () {
    final violations = sourceFiles
        .map((file) => file.path)
        .where((path) => RegExp(r'/domain/[^/]+\.dart$').hasMatch(path))
        .toList();

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('game domain stays independent from application settings', () {
    final violations = _violations(
      sourceFiles.where((file) => file.path.contains('/features/game/domain/')),
      (importPath, _) =>
          importPath.startsWith('package:xo_arena/shared/settings/'),
    );

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('data sources live inside responsibility folders', () {
    final violations = sourceFiles
        .map((file) => file.path)
        .where((path) => RegExp(r'/data/[^/]+\.dart$').hasMatch(path))
        .toList();

    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}

List<String> _violations(
  Iterable<File> files,
  bool Function(String importPath, String sourcePath) isForbidden,
) {
  final violations = <String>[];
  final importPattern = RegExp(r"^import '([^']+)';", multiLine: true);
  for (final file in files) {
    final source = file.readAsStringSync();
    for (final match in importPattern.allMatches(source)) {
      final importPath = match.group(1)!;
      if (isForbidden(importPath, file.path)) {
        violations.add('${file.path}: $importPath');
      }
    }
  }
  return violations;
}

String? _featureName(String path) {
  return RegExp(r'/features/([^/]+)/').firstMatch(path)?.group(1);
}
