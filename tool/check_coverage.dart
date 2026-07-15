import 'dart:io';

const defaultMinimumLineCoverage = 90.0;
const defaultMinimumBranchCoverage = 85.0;

final class CoverageSummary {
  const CoverageSummary({
    required this.hitLines,
    required this.totalLines,
    required this.hitBranches,
    required this.totalBranches,
  });

  final int hitLines;
  final int totalLines;
  final int hitBranches;
  final int totalBranches;

  double get linePercentage => _percentage(hitLines, totalLines);

  double get branchPercentage => _percentage(hitBranches, totalBranches);

  static double _percentage(int hit, int total) {
    return total == 0 ? 100 : hit * 100 / total;
  }
}

CoverageSummary summarizeLcov(String source) {
  final coveredLines = <String>{};
  final executableLines = <String>{};
  final coveredBranches = <String>{};
  final executableBranches = <String>{};
  var currentFile = '';
  var includeCurrentFile = false;

  for (final line in source.split('\n')) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3).replaceAll('\\', '/');
      includeCurrentFile = _includesSource(currentFile);
      continue;
    }
    if (!includeCurrentFile) continue;

    if (line.startsWith('DA:')) {
      final fields = line.substring(3).split(',');
      if (fields.length < 2) continue;
      final id = '$currentFile:${fields[0]}';
      executableLines.add(id);
      if ((int.tryParse(fields[1]) ?? 0) > 0) coveredLines.add(id);
      continue;
    }

    if (line.startsWith('BRDA:')) {
      final fields = line.substring(5).split(',');
      if (fields.length < 4) continue;
      final id = '$currentFile:${fields[0]}:${fields[1]}:${fields[2]}';
      executableBranches.add(id);
      if (fields[3] != '-' && (int.tryParse(fields[3]) ?? 0) > 0) {
        coveredBranches.add(id);
      }
    }
  }

  return CoverageSummary(
    hitLines: coveredLines.length,
    totalLines: executableLines.length,
    hitBranches: coveredBranches.length,
    totalBranches: executableBranches.length,
  );
}

bool _includesSource(String path) {
  return path.startsWith('lib/') &&
      !path.endsWith('.g.dart') &&
      !path.endsWith('.freezed.dart') &&
      !path.startsWith('lib/l10n/generated/');
}

Future<void> main(List<String> arguments) async {
  final reportPath = _value(arguments, '--report=') ?? 'coverage/lcov.info';
  final minimumLines = _threshold(
    arguments,
    '--min-lines=',
    defaultMinimumLineCoverage,
  );
  final minimumBranches = _threshold(
    arguments,
    '--min-branches=',
    defaultMinimumBranchCoverage,
  );
  final report = File(reportPath);
  if (!report.existsSync()) {
    stderr.writeln('Coverage report not found: $reportPath');
    exitCode = 2;
    return;
  }

  final summary = summarizeLcov(await report.readAsString());
  stdout.writeln(
    'Line coverage: ${summary.linePercentage.toStringAsFixed(2)}% '
    '(${summary.hitLines}/${summary.totalLines})',
  );
  stdout.writeln(
    'Branch coverage: ${summary.branchPercentage.toStringAsFixed(2)}% '
    '(${summary.hitBranches}/${summary.totalBranches})',
  );

  var failed = false;
  if (summary.linePercentage < minimumLines) {
    stderr.writeln(
      'Line coverage must be at least ${minimumLines.toStringAsFixed(2)}%.',
    );
    failed = true;
  }
  if (summary.branchPercentage < minimumBranches) {
    stderr.writeln(
      'Branch coverage must be at least '
      '${minimumBranches.toStringAsFixed(2)}%.',
    );
    failed = true;
  }
  if (failed) exitCode = 1;
}

String? _value(List<String> arguments, String prefix) {
  for (final argument in arguments) {
    if (argument.startsWith(prefix)) return argument.substring(prefix.length);
  }
  return null;
}

double _threshold(List<String> arguments, String prefix, double fallback) {
  final value = _value(arguments, prefix);
  if (value == null) return fallback;
  return double.parse(value);
}
