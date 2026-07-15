import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_coverage.dart';

void main() {
  test('summarizes handwritten line and branch coverage', () {
    final summary = summarizeLcov('''
SF:lib/features/game/domain/game.dart
DA:10,3
DA:11,0
BRDA:11,0,0,2
BRDA:11,0,1,0
end_of_record
''');

    expect(summary.hitLines, 1);
    expect(summary.totalLines, 2);
    expect(summary.linePercentage, 50);
    expect(summary.hitBranches, 1);
    expect(summary.totalBranches, 2);
    expect(summary.branchPercentage, 50);
  });

  test('excludes generated and localization sources', () {
    final summary = summarizeLcov('''
SF:lib/features/game/presentation/game_notifier.g.dart
DA:10,0
BRDA:10,0,0,0
end_of_record
SF:lib/shared/settings/domain/app_settings.freezed.dart
DA:20,0
end_of_record
SF:lib/l10n/generated/app_localizations.dart
DA:30,0
end_of_record
SF:lib/features/game/domain/game.dart
DA:40,1
end_of_record
''');

    expect(summary.hitLines, 1);
    expect(summary.totalLines, 1);
    expect(summary.hitBranches, 0);
    expect(summary.totalBranches, 0);
    expect(summary.branchPercentage, 100);
  });
}
