import 'package:dart_apitool/api_tool.dart';
import 'package:test/test.dart';

import '../helper/integration_test_helper.dart';

void main() {
  test('retains the names of shorthand factory constructors', () async {
    final packageApi = await PackageApiAnalyzer(
      packagePath: 'test/test_packages/shorthand_factory_constructors',
    ).analyzePrepared();

    final benchmarkMetrics = packageApi.interfaceDeclarations.singleWhere(
      (declaration) => declaration.name == 'BenchmarkMetrics',
    );
    final constructorNames = benchmarkMetrics.executableDeclarations
        .where((declaration) => declaration.type == ExecutableType.constructor)
        .map((declaration) => declaration.name);

    expect(constructorNames, containsAll(['new', 'fromSamples', 'fromJson']));
  });
}
