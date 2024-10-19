// detection_result.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'disease_detail.dart';

class DetectionResult extends StatelessWidget {
  final String diseaseName;
  final double accuracy;
  final String imagePath;
  // Kept treatments and preventiveMeasures for navigation purposes
  final String treatments;
  final String preventiveMeasures;

  const DetectionResult({
    super.key,
    required this.diseaseName,
    required this.accuracy,
    required this.imagePath,
    required this.treatments,
    required this.preventiveMeasures,
  });

  @override
  Widget build(BuildContext context) {
    // Fetch screen width
    double screenWidth = MediaQuery.of(context).size.width;

    // Define image size (square)
    double imageSize = screenWidth - 32; // 16*2 padding

    // Optional: Set a maximum size for larger screens
    if (imageSize > 300) imageSize = 300;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detection Result'),
        automaticallyImplyLeading: false, // Remove the default back button
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.center, // Center-align the children
          children: [
            // Display the image used for detection with rounded corners
            ClipRRect(
              borderRadius: BorderRadius.circular(20), // Rounded corners
              child: Image.file(
                File(imagePath),
                height: imageSize,
                width: imageSize,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: imageSize,
                    width: imageSize,
                    color: Colors.grey[300],
                    child: const Center(child: Text('Image not available')),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Display detected disease name (center-aligned and italicized)
            Text(
              'Disease: $diseaseName',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // Display accuracy percentage (center-aligned and italicized)
            Text(
              'Accuracy: ${accuracy.toStringAsFixed(2)}%',
              style: const TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40), // Increased spacing before buttons
            // Center-aligned buttons arranged vertically
            Center(
              child: Column(
                children: [
                  // Show More Info Button (full width and larger)
                  SizedBox(
                    width: double
                        .infinity, // Make the button take full width within padding
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to DiseaseDetails with all information
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DiseaseDetails(
                              diseaseName: diseaseName,
                              imagePath: imagePath,
                              treatments: treatments,
                              preventiveMeasures: preventiveMeasures,
                              severity: '',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.info_outline),
                      label: const Text(
                        'Show More Info',
                        style: TextStyle(fontSize: 18), // Larger font size
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20), // Increased padding
                        textStyle: const TextStyle(fontSize: 16),
                        minimumSize:
                            const Size(double.infinity, 60), // Increased height
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Close Button with 'X' Icon (smaller size)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                      label: const Text(
                        'Close',
                        style: TextStyle(fontSize: 14), // Smaller font size
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red, // Ensures text is white
                        padding: const EdgeInsets.symmetric(
                            vertical: 10), // Smaller padding
                        minimumSize:
                            const Size(double.infinity, 40), // Smaller height
                      ),
                    ),
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
