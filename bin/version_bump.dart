import 'dart:io';

/// Automated Version Bumper for Flutter (V4.1)
///
/// Usage:
/// dart bin/version_bump.dart --patch  (Increments 1.0.0+1 -> 1.0.1+1)
/// dart bin/version_bump.dart --build  (Increments 1.0.0+1 -> 1.0.0+2)
void main(List<String> args) {
  final file = File('pubspec.yaml');
  if (!file.existsSync()) {
    print('❌ Error: pubspec.yaml not found.');
    exit(1);
  }

  final lines = file.readAsLinesSync();
  final versionIndex = lines.indexWhere((l) => l.trim().startsWith('version:'));

  if (versionIndex == -1) {
    print('❌ Error: "version:" not found in pubspec.yaml.');
    exit(1);
  }

  final versionLine = lines[versionIndex];
  final currentVersionMatch = RegExp(
    r'version:\s*(?<semver>[0-9.]+)\+(?<build>[0-9]+)',
  ).firstMatch(versionLine);

  if (currentVersionMatch == null) {
    print(
      '❌ Error: Invalid version format in pubspec.yaml. Expected: version: X.Y.Z+W',
    );
    exit(1);
  }

  final String majorMinorPatch = currentVersionMatch.namedGroup('semver')!;
  int buildNumber = int.parse(currentVersionMatch.namedGroup('build')!);

  if (args.contains('--status')) {
    print('🛡️ Current Project Version: $majorMinorPatch+$buildNumber');
    exit(0);
  }

  final parts = majorMinorPatch.split('.').map(int.parse).toList();

  if (args.contains('--patch')) {
    parts[2]++;
    print('🚀 Incrementing Patch: $majorMinorPatch -> ${parts.join('.')}');
  } else if (args.contains('--build')) {
    buildNumber++;
    print('🚀 Incrementing Build: $buildNumber -> $buildNumber');
  } else if (args.contains('--minor')) {
    parts[1]++;
    parts[2] = 0;
    print('🚀 Incrementing Minor: $majorMinorPatch -> ${parts.join('.')}');
  } else if (args.contains('--major')) {
    parts[0]++;
    parts[1] = 0;
    parts[2] = 0;
    print('🚀 Incrementing Major: $majorMinorPatch -> ${parts.join('.')}');
  } else {
    print('ℹ️ Usage: --major | --minor | --patch | --build | --status');
    exit(0);
  }

  final newVersion = '${parts.join('.')}+$buildNumber';
  lines[versionIndex] = 'version: $newVersion';

  file.writeAsStringSync('${lines.join('\n')}\n');
  print('✅ Successfully updated pubspec.yaml to version: $newVersion');
}
