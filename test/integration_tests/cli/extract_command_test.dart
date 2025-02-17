import 'package:args/command_runner.dart';
import 'package:dart_apitool/api_tool_cli.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

void main() {
  group('Extract command', () {
    test('Can handle complex path dependencies', () async {
      final extractCommand = ExtractCommand();
      final runner =
          CommandRunner<int>('dart_apitool_tests', 'Test for dart_apitool')
            ..addCommand(extractCommand);
      // executes "extract" command for a set of packages that is linked via path dependencies
      // using "expect()" here results in an early return due to FakeAsync not being able to handle this
      final exitCode = await runner.run([
        'extract',
        '--input',
        path.join(
          'test',
          'test_packages',
          'path_references',
          'cluster_a',
          'package_a',
        ),
        '--include-path-dependencies',
      ]);
      expect(exitCode, 0);
    });
    test(
        'Fails with path dependencies pointing outside without include-path-dependencies argument',
        () async {
      final extractCommand = ExtractCommand();
      final runner =
          CommandRunner<int>('dart_apitool_tests', 'Test for dart_apitool')
            ..addCommand(extractCommand);
      // executes "extract" command for a set of packages that is linked via path dependencies
      // using "expect()" here results in an early return due to FakeAsync not being able to handle this
      Object? catchedException;
      try {
        await runner.run([
          'extract',
          '--input',
          path.join(
            'test',
            'test_packages',
            'path_references',
            'cluster_a',
            'package_a',
          ),
          // ommitting --include-path-dependencies
        ]);
      } catch (e) {
        catchedException = e;
      }
      expect(catchedException, isA<RunDartError>());
    });

    test('Can handle pub ref with --include-path-dependencies', () async {
      final extractCommand = ExtractCommand();
      final runner =
          CommandRunner<int>('dart_apitool_tests', 'Test for dart_apitool')
            ..addCommand(extractCommand);
      // executes "extract" command for a set of packages that is linked via path dependencies
      // using "expect()" here results in an early return due to FakeAsync not being able to handle this
      await runner.run([
        'extract',
        '--input',
        'pub://dart_apitool/0.5.0',
        '--include-path-dependencies',
      ]);
    });

    test('Can handle pub ref', () async {
      final extractCommand = ExtractCommand();
      final runner =
          CommandRunner<int>('dart_apitool_tests', 'Test for dart_apitool')
            ..addCommand(extractCommand);
      // executes "extract" command for a set of packages that is linked via path dependencies
      // using "expect()" here results in an early return due to FakeAsync not being able to handle this
      await runner.run([
        'extract',
        '--input',
        'pub://dart_apitool/0.4.0',
      ]);
    });

    test('Can handle nested path dependencies', () async {
      final extractCommand = ExtractCommand();
      final runner =
          CommandRunner<int>('dart_apitool_tests', 'Test for dart_apitool')
            ..addCommand(extractCommand);
      // executes "extract" command for a set of packages that is linked via path dependencies
      // using "expect()" here results in an early return due to FakeAsync not being able to handle this
      final exitCode = await runner.run([
        'extract',
        '--input',
        path.join(
          'test',
          'test_packages',
          'nested_path_references',
          'package_a',
        ),
        '--include-path-dependencies',
      ]);
      expect(exitCode, 0);
    });
  }, timeout: Timeout(Duration(minutes: 2)));
}
