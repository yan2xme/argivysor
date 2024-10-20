// detection_result.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'disease_detail.dart';
import 'plant_library.dart'; // Import DiseaseRepository

class DetectionResult extends StatelessWidget {
  final String diseaseName;
  final double accuracy;
  final String imagePath;

  const DetectionResult({
    super.key,
    required this.diseaseName,
    required this.accuracy,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate screen width
    double screenWidth = MediaQuery.of(context).size.width;
    double imageSize = screenWidth - 32;
    if (imageSize > 400) imageSize = 400;

    // Fetch disease details from the repository
    Disease? diseaseDetails = DiseaseRepository.getDiseaseByName(diseaseName);

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Detection Result'),
        ),
        automaticallyImplyLeading: false, // Removes the back button
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display the user's photo
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
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
              Text(
                'Disease: $diseaseName',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SFProDisplay',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Accuracy: ${accuracy.toStringAsFixed(2)}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'SFProDisplay',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Show more info button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (diseaseDetails == null) {
                            // Handle case where disease details are not found
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Disease details not found.'),
                              ),
                            );
                            return;
                          }
                          // Navigate to DiseaseDetails and pass both disease and imagePath
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DiseaseDetails(
                                disease: diseaseDetails,
                                userImagePath:
                                    imagePath, // Pass the imagePath here
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.info_outline),
                        label: const Text(
                          'Show More Info',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'SFProDisplay',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          minimumSize: const Size(double.infinity, 60),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Close button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                        label: const Text(
                          'Close',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'SFProDisplay',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          minimumSize: const Size(double.infinity, 40),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
