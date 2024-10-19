// detect_tab.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart'; // Import TFLite library
import 'dart:io';
import 'dart:developer' as devtools;
import 'detection_result.dart';
import 'plant_library.dart'; // For DiseaseRepository

class DetectTab extends StatefulWidget {
  const DetectTab({super.key});

  @override
  DetectTabState createState() => DetectTabState();
}

class DetectTabState extends State<DetectTab> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  // Load the TFLite model
  Future<void> _loadModel() async {
    try {
      String? res = await Tflite.loadModel(
        model: "assets/model_unquant.tflite",
        labels: "assets/labels.txt",
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false,
      );
      devtools.log("Model loaded: $res");
    } catch (e) {
      devtools.log("Error loading model: $e");
    }
  }

  // Method to pick an image from the specified source
  void _pickImage(BuildContext context, ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) {
        devtools.log("Image selection cancelled");
        return;
      }

      devtools.log("Image Picked: ${image.path}");
      setState(() {
        _isLoading = true;
      });

      // Perform image classification
      if (mounted) {
        await _classifyImageRunModelOnImage(File(image.path), context);
      }
    } catch (e) {
      devtools.log("Error picking image: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Method to classify the image using the loaded TFLite model
  Future<void> _classifyImageRunModelOnImage(
      File image, BuildContext context) async {
    try {
      devtools.log("Starting image classification...");
      var recognitions = await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 5,
        threshold: 0.2,
        asynch: true,
      );

      if (recognitions == null || recognitions.isEmpty) {
        devtools.log("No recognitions found.");
        setState(() {
          _isLoading = false;
        });
        _showNoDetectionDialog(context);
        return;
      }

      devtools.log("Recognitions: $recognitions");

      setState(() {
        if (recognitions.isNotEmpty) {
          String detectedDisease = recognitions[0]['label'].toString();
          double confidence = (recognitions[0]['confidence'] * 100);

          // Fetch disease details from the repository
          DiseaseRepository.getDiseaseByName(detectedDisease);

          // Navigate to DetectionResult screen with the result
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetectionResult(
                  diseaseName: detectedDisease,
                  accuracy: confidence,
                  imagePath: image.path, // User's photo path
                ),
              ),
            );
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      devtools.log("Error during classification: $e");
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(context, "An error occurred during classification.");
    }
  }

  // Display a dialog when no disease is detected
  void _showNoDetectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Disease Detected'),
          content: const Text('The system could not detect any disease.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Display an error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isLoading
          ? const CircularProgressIndicator()
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Photo'),
                  onPressed: () => _pickImage(context, ImageSource.camera),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 70, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Choose from Gallery'),
                  onPressed: () => _pickImage(context, ImageSource.gallery),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 35, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
    );
  }
}
