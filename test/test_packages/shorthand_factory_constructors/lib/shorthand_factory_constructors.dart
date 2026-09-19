// @dart=3.13

final class const BenchmarkMetrics({required final double meanNs}) {
  factory fromSamples(List<double> samplesNs) =>
      BenchmarkMetrics(meanNs: samplesNs.first);

  factory fromJson(Map<String, Object?> json) =>
      BenchmarkMetrics(meanNs: json['meanNs']! as double);
}
