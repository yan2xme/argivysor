// disease_detail.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:classifier/plant_library.dart'; // Import Disease model

class DiseaseDetails extends StatelessWidget {
  final Disease disease;
  final String? userImagePath;

  const DiseaseDetails({
    super.key, // Use super.key for cleaner constructor
    required this.disease,
    this.userImagePath,
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

  // Function to format text as bullet points
  Widget _buildBulletPoints(List<String> contentList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contentList.map((content) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('• ', style: TextStyle(fontSize: 16)),
            Expanded(
              child: Text(content, style: const TextStyle(fontSize: 16)),
            ),
          ],
        );
      }).toList(),
    );
  }

  // Function to build the disease image (asset or file)
  Widget _buildDiseaseImage() {
    // Display the user-captured image if available, else show the reference image
    if (userImagePath != null && userImagePath!.isNotEmpty) {
      return Image.file(
        File(userImagePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(child: Text('Image not available')),
          );
        },
      );
    } else {
      return Image.asset(
        disease.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(child: Text('Image not available')),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color severityColor = _getSeverityColor(disease.severity);
    double severityPercent = _getSeverityPercentage(disease.severity);

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            disease.name,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the disease's image (reference or user captured)
            AspectRatio(
              aspectRatio: 1.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _buildDiseaseImage(),
              ),
            ),
            const SizedBox(height: 20),

            // Disease name with severity level
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Icon(
                    Icons.eco,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    disease.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Disease Description
            Text(
              disease.description,
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.normal,
              ),
            ),
            const SizedBox(height: 20),

            // Severity level indicator
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Severity Level: ${disease.severity}',
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

            // Recommended Treatments with bullet points
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
                  _buildBulletPoints(disease.treatments),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Preventive Measures with bullet points
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
                  _buildBulletPoints(disease.preventiveMeasures),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
