import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:colorize/colorize.dart';
import 'package:dart_apitool/api_tool.dart';
import 'package:pub_semver/pub_semver.dart';

import '../package_ref.dart';
import 'command_mixin.dart';

String _optionNameOld = 'old';
String _optionNameNew = 'new';
String _optionNameCheckVersions = 'check-versions';

class DiffCommand extends Command<int> with CommandMixin {
  @override
  final name = "diff";
  @override
  final description = "Creates a diff of 2 given packages.";

  DiffCommand() {
    argParser.addOption(
      _optionNameOld,
      mandatory: true,
      help: 'Old package reference. $packageRefExplanation',
    );
    argParser.addOption(
      _optionNameNew,
      mandatory: true,
      help: 'New package reference. $packageRefExplanation',
    );
    argParser.addFlag(
      _optionNameCheckVersions,
      help:
          'Determines if the version change matches the actual changes. Influences tool return value',
      defaultsTo: true,
      negatable: true,
    );
  }

  @override
  Future<int> run() async {
    final oldPackageRef = PackageRef(argResults![_optionNameOld]);
    final newPackageRef = PackageRef(argResults![_optionNameNew]);
    final checkVersions = argResults![_optionNameCheckVersions] as bool;

    await prepare(oldPackageRef);
    await prepare(newPackageRef);

    final oldPackageApi = await analyze(oldPackageRef);
    final newPackageApi = await analyze(newPackageRef);

    final differ = PackageApiDiffer();
    final diffResult =
        differ.diff(oldApi: oldPackageApi, newApi: newPackageApi);

    // print the diffs
    if (diffResult.hasChanges) {
      final breakingChanges = _printApiChangeNode(diffResult.rootNode, true);
      if (breakingChanges == null) {
        stdout.writeln('No breaking changes!');
      } else {
        stdout.writeln('BREAKING CHANGES:');
        stdout.write(breakingChanges);
      }
      final nonBreakingChanges =
          _printApiChangeNode(diffResult.rootNode, false);
      if (nonBreakingChanges == null) {
        stdout.writeln('No non-breaking changes!');
      } else {
        stdout.writeln('Non-Breaking changes');
        stdout.write(nonBreakingChanges);
      }
    } else {
      stdout.writeln('No changes detected!');
    }

    if (checkVersions &&
        !_versionChangeMatchesChanges(
            diffResult: diffResult,
            oldPackageApi: oldPackageApi,
            newPackageApi: newPackageApi)) {
      return -1;
    }

    return 0;
  }

  String? _printApiChangeNode(ApiChangeTreeNode node, bool breaking,
      [int level = 0]) {
    final currentOutput = StringBuffer();
    bool headlinePrinted = false;

    String getIndent(int level) {
      if (level < 0) {
        return '';
      }
      return List<String>.filled(level * 4, ' ').join('');
    }

    String getDeclarationNodeHeadline(Declaration declaration) {
      var prefix = '';
      if (declaration is ExecutableDeclaration) {
        switch (declaration.type) {
          case ExecutableType.constructor:
            prefix = 'Constructor ';
            break;
          case ExecutableType.method:
            prefix = 'Method ';
            break;
        }
      } else if (declaration is FieldDeclaration) {
        prefix = 'Field ';
      } else if (declaration is ClassDeclaration) {
        prefix = 'Class ';
      }
      return prefix + declaration.name;
    }

    void ensureHeadline() {
      if (headlinePrinted) {
        return;
      }
      if (node.nodeDeclaration != null) {
        currentOutput.write(getIndent(level));
        currentOutput
            .writeln(getDeclarationNodeHeadline(node.nodeDeclaration!));
      }
      headlinePrinted = true;
    }

    for (final child in node.children.values) {
      final childOutput = _printApiChangeNode(child, breaking, level + 1);
      if (childOutput != null) {
        ensureHeadline();
        currentOutput.write(childOutput);
      }
    }
    final filteredChanges =
        node.changes.where((change) => change.type.isBreaking == breaking);
    if (filteredChanges.isNotEmpty) {
      for (final change in filteredChanges) {
        ensureHeadline();
        currentOutput.write(getIndent(level));
        currentOutput.write('- ');
        currentOutput.writeln(change.changeDescription);
      }
    }
    return currentOutput.isEmpty ? null : currentOutput.toString();
  }

  bool _versionChangeMatchesChanges({
    required PackageApiDifResult diffResult,
    required PackageApi oldPackageApi,
    required PackageApi newPackageApi,
  }) {
    stdout.writeln('');
    stdout.writeln('Checking Package version');
    stdout.writeln('');
    if (oldPackageApi.packageVersion == null) {
      throw PackageApiDiffError(
          message: 'Old package doesn\'t contain a version]');
    }
    if (newPackageApi.packageVersion == null) {
      throw PackageApiDiffError(
          message: 'New package doesn\'t contain a version]');
    }
    final oldVersion = Version.parse(oldPackageApi.packageVersion!);
    final newVersion = Version.parse(newPackageApi.packageVersion!);

    bool containsAnyChanges = diffResult.hasChanges;
    bool containsBreakingChanges =
        diffResult.apiChanges.any((change) => change.type.isBreaking);

    Version expectedMinVersion = oldVersion.nextPatch;
    String versionExplanation = 'no changes';
    if (containsBreakingChanges) {
      expectedMinVersion = oldVersion.nextBreaking;
      versionExplanation = 'breaking changes';
    } else if (containsAnyChanges) {
      expectedMinVersion = oldVersion.nextMinor;
      versionExplanation = 'non-breaking changes';
    }

    stdout.writeln('Old version: "$oldVersion"');
    stdout.writeln(
        'Expecting minimum version: "$expectedMinVersion" ($versionExplanation)');
    if (newVersion <= expectedMinVersion) {
      stdout.writeln(Colorize('New Version is too low!').red());
      stdout.writeln(
          'Got "${Colorize(newVersion.toString()).bold()}" expected >= "${Colorize(expectedMinVersion.toString()).bold()}"');
      return false;
    } else {
      stdout.writeln(Colorize('New version is OK!').green());
      stdout.writeln(
          'Got "${Colorize(newVersion.toString()).bold()}" which is >= "${Colorize(expectedMinVersion.toString()).bold()}"');
      return true;
    }
  }
}
