import 'package:flutter/material.dart';

class DiseaseDetails extends StatelessWidget {
  final String diseaseName;
  final String imagePath;
  final String severity;
  final String treatments;
  final String preventiveMeasures;

  const DiseaseDetails({
    super.key,
    required this.diseaseName,
    required this.imagePath,
    required this.severity,
    required this.treatments,
    required this.preventiveMeasures,
  });

  // Function to get severity color based on the severity level
  Color _getSeverityColor(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Function to get severity percentage for the progress indicator
  double _getSeverityPercentage(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return 0.33;
      case 'moderate':
        return 0.66;
      case 'high':
        return 1.0;
      default:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color severityColor = _getSeverityColor(severity);
    double severityPercent = _getSeverityPercentage(severity);

    return Scaffold(
      appBar: AppBar(
        title: Text(diseaseName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the disease image
            AspectRatio(
              aspectRatio: 1.0,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, size: 50);
                },
              ),
            ),

            const SizedBox(height: 20),
            // Disease name with severity level
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Icon(
                    Icons.eco, // Leaf icon
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  diseaseName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Severity level indicator
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Severity Level: $severity',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 5),
            LinearProgressIndicator(
              value: severityPercent,
              color: severityColor,
              backgroundColor: Colors.grey.shade300,
              minHeight: 10,
            ),
            const SizedBox(height: 20),
            // Recommended Treatments
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommended Treatments',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    treatments,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Preventive Measures
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.yellow.shade50,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.yellow.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preventive Measures',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow.shade800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    preventiveMeasures,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
