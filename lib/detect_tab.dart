// detect_tab.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart'; // Import TFLite library
import 'dart:io';
import 'dart:developer' as devtools;
import 'detection_result.dart';
import 'plant_library.dart';

class DetectTab extends StatefulWidget {
  const DetectTab({super.key});

  @override
  _DetectTabState createState() => _DetectTabState();

  void handleImage(BuildContext context, XFile image) {}
}

class _DetectTabState extends State<DetectTab> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

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

      // Perform inference
      await _classifyImageRunModelOnImage(File(image.path), context);
    } catch (e) {
      devtools.log("Error picking image: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

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
        return;
      }

      devtools.log("Recognitions: $recognitions");

      setState(() {
        if (recognitions.isNotEmpty) {
          String detectedDisease = recognitions[0]['label'].toString();
          double confidence = (recognitions[0]['confidence'] * 100);

          // Navigate to DetectionResult screen with the result
          Disease? diseaseDetails =
              PlantLibrary.getDiseaseByName(detectedDisease);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetectionResult(
                diseaseName: detectedDisease,
                accuracy: confidence,
                imagePath: image.path,
                treatments:
                    diseaseDetails?.treatments ?? 'Information unavailable',
                preventiveMeasures: diseaseDetails?.preventiveMeasures ??
                    'Information unavailable',
              ),
            ),
          );
        }
        _isLoading = false;
      });
    } catch (e) {
      devtools.log("Error during classification: $e");
      setState(() {
        _isLoading = false;
      });
    }
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
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Choose from Gallery'),
                  onPressed: () => _pickImage(context, ImageSource.gallery),
                ),
              ],
            ),
    );
  }
}
