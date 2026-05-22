class ClassificationResult {
  final String plantName;
  final String diseaseName;
  final double confidence;

  const ClassificationResult({
    required this.plantName,
    required this.diseaseName,
    required this.confidence,
  });
}