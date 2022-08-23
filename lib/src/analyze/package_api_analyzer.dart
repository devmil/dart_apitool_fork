// ignore_for_file: avoid_print

import 'dart:collection';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart' hide File;
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:dart_apitool/src/analyze/api_relevant_elements_collector.dart';
import 'package:dart_apitool/src/analyze/exported_files_collector.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart' as path;
import 'package:pubspec_parse/pubspec_parse.dart';

import '../model/class_declaration.dart';
import '../model/executable_declaration.dart';
import '../model/field_declaration.dart';
import '../model/internal/internal_class_declaration.dart';
import '../model/internal/internal_executable_declaration.dart';
import '../model/internal/internal_field_declaration.dart';
import '../model/package_api.dart';
import '../utils/string_utils.dart';

part 'package_api_analyzer.freezed.dart';

/// this class analyzes the public package API of a given package ([packagePath])
class PackageApiAnalyzer {
  /// path to the package to analyze
  final String packagePath;

  /// constructor
  PackageApiAnalyzer({required this.packagePath}) {
    _checkProjectPathValidity();
  }

  /// analyzes the configured package and returns a model of its public API
  Future<PackageApi> analyze() async {
    final normalizedAbsoluteProjectPath =
        _getNormalizedAbsolutePath(packagePath);

    final yamlContent =
        await File(path.join(normalizedAbsoluteProjectPath, 'pubspec.yaml'))
            .readAsString();
    final pubSpec = Pubspec.parse(yamlContent);

    final resourceProvider = PhysicalResourceProvider.INSTANCE;

    final normalizedAbsolutePublicEntrypointPath = _getNormalizedAbsolutePath(
        path.join(normalizedAbsoluteProjectPath, 'lib'));

    final contextCollection = _createAnalysisContextCollection(
      path: normalizedAbsoluteProjectPath,
      resourceProvider: resourceProvider,
    );

    final collectedClasses = <int?, _ClassCollectionResult>{};

    final analyzedFiles = List<_FileToAnalyzeEntry>.empty(growable: true);
    final filesToAnalyze = Queue<_FileToAnalyzeEntry>();
    filesToAnalyze.addAll(
        _findPublicFilesInProject(normalizedAbsolutePublicEntrypointPath));

    while (filesToAnalyze.isNotEmpty) {
      final fileToAnalyze = filesToAnalyze.first;
      filesToAnalyze.removeFirst();
      analyzedFiles.add(fileToAnalyze);

      try {
        final context = contextCollection.contextFor(fileToAnalyze.filePath);

        final unitResult = await context.currentSession
            .getResolvedUnit(fileToAnalyze.filePath);
        if (unitResult is ResolvedUnitResult) {
          if (!unitResult.isPart) {
            final collector = APIRelevantElementsCollector(
              shownNames: fileToAnalyze.shownNames,
              hiddenNames: fileToAnalyze.hiddenNames,
            );
            unitResult.libraryElement.accept(collector);
            final skippedClasses = <int>[];
            for (final cd in collector.classDeclarations) {
              if (!collectedClasses.containsKey(cd.id)) {
                collectedClasses[cd.id] = _ClassCollectionResult();
              }
              if (!collectedClasses[cd.id]!
                  .classDeclarations
                  .any((cdToCheck) => cdToCheck.id == cd.id)) {
                collectedClasses[cd.id]!.classDeclarations.add(cd);
              } else {
                skippedClasses.add(cd.id);
              }
            }
            for (final exd in collector.executableDeclarations) {
              if (skippedClasses.contains(exd.parentClassId)) {
                continue;
              }
              if (!collectedClasses.containsKey(exd.parentClassId)) {
                collectedClasses[exd.parentClassId] = _ClassCollectionResult();
              }
              collectedClasses[exd.parentClassId]!
                  .executableDeclarations
                  .add(exd);
            }
            for (final fd in collector.fieldDeclarations) {
              if (skippedClasses.contains(fd.parentClassId)) {
                continue;
              }
              if (!collectedClasses.containsKey(fd.parentClassId)) {
                collectedClasses[fd.parentClassId] = _ClassCollectionResult();
              }
              collectedClasses[fd.parentClassId]!.fieldDeclarations.add(fd);
            }
          }

          final referencedFilesCollector = ExportedFilesCollector();
          unitResult.libraryElement.accept(referencedFilesCollector);
          for (final fileRef in referencedFilesCollector.fileReferences) {
            if (!_isInternalRef(
                originLibrary: fileRef.originLibrary,
                refLibrary: fileRef.referencedLibrary)) {
              continue;
            }
            final relativeUri =
                _getRelativeUriFromLibraryIdentifier(fileRef.uri);
            final referencedFilePath = path.normalize(
                path.join(path.dirname(fileToAnalyze.filePath), relativeUri));
            final analyzeEntry = _FileToAnalyzeEntry(
              filePath: referencedFilePath,
              shownNames: fileRef.shownNames,
              hiddenNames: fileRef.hiddenNames,
            );
            if (!analyzedFiles.contains(analyzeEntry) &&
                !filesToAnalyze.contains(analyzeEntry)) {
              filesToAnalyze.add(analyzeEntry);
            }
          }
        }
      } on StateError catch (e) {
        print('Problem parsing $fileToAnalyze: $e');
      }
    }

    final projectClassDeclarations =
        List<ClassDeclaration>.empty(growable: true);
    final projectExecutableDeclarations =
        List<ExecutableDeclaration>.empty(growable: true);
    final projectFieldDeclarations =
        List<FieldDeclaration>.empty(growable: true);

    // aggregate class declrations
    for (final classId in collectedClasses.keys) {
      final entry = collectedClasses[classId]!;
      if (entry.classDeclarations.isEmpty) {
        projectExecutableDeclarations.addAll(
            entry.executableDeclarations.map((e) => e.executableDeclaration));
        projectFieldDeclarations
            .addAll(entry.fieldDeclarations.map((e) => e.fieldDeclaration));
      } else {
        assert(entry.classDeclarations.length == 1,
            'We found multiple classes sharing the same classId!');
        final cd = entry.classDeclarations.first;
        projectClassDeclarations.add(
          cd.classDeclaration.copyWith(
            executableDeclarations: [
              ...cd.classDeclaration.executableDeclarations,
              ...entry.executableDeclarations
                  .map((e) => e.executableDeclaration),
            ],
            fieldDeclarations: [
              ...cd.classDeclaration.fieldDeclarations,
              ...entry.fieldDeclarations.map((e) => e.fieldDeclaration),
            ],
          ),
        );
      }
    }
    final normalizedProjectPath = path.normalize(path.absolute(packagePath));
    return PackageApi(
      packageName: pubSpec.name,
      packageVersion: pubSpec.version?.toString(),
      packagePath: normalizedProjectPath,
      classDeclarations: projectClassDeclarations,
      executableDeclarations: projectExecutableDeclarations,
      fieldDeclarations: projectFieldDeclarations,
    );
  }

  String _getNormalizedAbsolutePath(String pathToNormalize) {
    return path.normalize(path.absolute(pathToNormalize));
  }

  Iterable<_FileToAnalyzeEntry> _findPublicFilesInProject(
      String normalizedAbsolutePath) {
    return Directory(normalizedAbsolutePath)
        .listSync(recursive: false)
        .where((file) => path.extension(file.path) == '.dart')
        .map((file) => _FileToAnalyzeEntry(
              filePath: path.normalize(path.absolute(file.path)),
            ));
  }

  AnalysisContextCollection _createAnalysisContextCollection({
    required String path,
    ResourceProvider? resourceProvider,
  }) {
    AnalysisContextCollection collection = AnalysisContextCollection(
      includedPaths: <String>[path],
      resourceProvider: resourceProvider ?? PhysicalResourceProvider.INSTANCE,
    );
    return collection;
  }

  String _getRelativeUriFromLibraryIdentifier(String libraryIdentifier) {
    if (!libraryIdentifier.contains('package:')) {
      return libraryIdentifier;
    }
    if (!libraryIdentifier.contains('/')) {
      throw ArgumentError.value(libraryIdentifier, 'libraryIdentifier',
          'Looks like a package (starts with \'package:\' but doesn\'t contain \'/\'');
    }
    return libraryIdentifier.substring(libraryIdentifier.indexOf('/'));
  }

  bool _isInternalRef(
      {required LibraryElement originLibrary,
      required LibraryElement? refLibrary}) {
    if (refLibrary == null) {
      return true;
    }
    final origPackageName = getPackageNameFromLibrary(originLibrary);
    final refPackageName = getPackageNameFromLibrary(refLibrary);

    return origPackageName == refPackageName;
  }

  void _checkProjectPathValidity() {
    final absoluteNormalizedPackagePath =
        path.normalize(path.absolute(packagePath));
    assert(Directory(absoluteNormalizedPackagePath).existsSync(),
        'Given package path doesn\'t exist ($absoluteNormalizedPackagePath)');
    final pubspecPath =
        path.join(absoluteNormalizedPackagePath, 'pubspec.yaml');
    assert(File(pubspecPath).existsSync(),
        'Given package path doesn\'t contain a pubspec.yaml ($absoluteNormalizedPackagePath)');
  }
}

class _ClassCollectionResult {
  final classDeclarations =
      List<InternalClassDeclaration>.empty(growable: true);
  final executableDeclarations =
      List<InternalExecutableDeclaration>.empty(growable: true);
  final fieldDeclarations =
      List<InternalFieldDeclaration>.empty(growable: true);
}

@freezed
class _FileToAnalyzeEntry with _$_FileToAnalyzeEntry {
  const factory _FileToAnalyzeEntry(
      {required String filePath,
      @Default([]) List<String> shownNames,
      @Default([]) List<String> hiddenNames}) = __FileToAnalyzeEntry;
}
