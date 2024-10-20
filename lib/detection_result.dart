import 'dart:io';
import 'package:flutter/material.dart';
import 'disease_detail.dart';
import 'plant_library.dart'; // Import DiseaseRepository
import 'package:path_provider/path_provider.dart'; // For file storage
import 'dart:convert'; // For JSON encoding/decoding
import 'dart:developer' as devtools; // For logging

class DetectionResult extends StatefulWidget {
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
  _DetectionResultState createState() => _DetectionResultState();
}

class _DetectionResultState extends State<DetectionResult> {
  List<Map<String, String>> inferenceHistory = [];
  bool _hasSaved = false; // Track whether the inference has been saved

  @override
  void initState() {
    super.initState();
    _logInference(); // Log the current inference when the page is loaded
  }

  // Function to log the current image inference
  Future<void> _logInference() async {
    if (_hasSaved) return; // Prevent multiple saves

    final DateTime now = DateTime.now();
    final String date = now.toString();

    final Map<String, String> inferenceData = {
      'diseaseName': widget.diseaseName,
      'accuracy': widget.accuracy.toStringAsFixed(2),
      'imagePath': widget.imagePath,
      'date': date,
    };

    // Save the updated history list to the file
    await _saveHistory(inferenceData);
    _hasSaved = true; // Mark as saved to prevent duplicates
  }

  // Save the inference history to local storage
  Future<void> _saveHistory(Map<String, String> newInference) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/inference_history.json');

    // Load existing history if the file exists
    if (await file.exists()) {
      final contents = await file.readAsString();
      // Decode and convert all dynamic maps to Map<String, String>
      List<dynamic> existingHistory = jsonDecode(contents);
      inferenceHistory = existingHistory.map((e) {
        return Map<String, String>.from(e);
      }).toList();
    }

    // Check if an inference with the same data already exists
    bool isDuplicate = inferenceHistory.any((element) =>
        element['diseaseName'] == newInference['diseaseName'] &&
        element['accuracy'] == newInference['accuracy'] &&
        element['imagePath'] == newInference['imagePath'] &&
        element['date'] == newInference['date']);

    if (!isDuplicate) {
      // Append the new inference to the existing history
      inferenceHistory.add(newInference);

      // Save the updated history back to the file
      String data = jsonEncode(inferenceHistory);
      await file.writeAsString(data);

      devtools.log("Inference saved: $data"); // Log for debugging
    } else {
      devtools.log("Duplicate inference not saved."); // Log for debugging
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate screen width
    double screenWidth = MediaQuery.of(context).size.width;
    double imageSize = screenWidth - 32;
    if (imageSize > 400) imageSize = 400;

    // Fetch disease details from the repository
    Disease? diseaseDetails =
        DiseaseRepository.getDiseaseByName(widget.diseaseName);

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
                  File(widget.imagePath),
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
                'Disease: ${widget.diseaseName}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SFProDisplay',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Accuracy: ${widget.accuracy.toStringAsFixed(2)}%',
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
                                    widget.imagePath, // Pass the imagePath here
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
