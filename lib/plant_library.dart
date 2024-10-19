import 'package:flutter/material.dart';
import 'disease_detail.dart';
import 'package:collection/collection.dart'; // For firstWhereOrNull

class PlantLibrary extends StatelessWidget {
  // Centralized disease data list
  static final List<Disease> diseases = [
    Disease(
      name: 'Banana Yellow Sigatoka',
      description: 'Fungal disease that affects banana plants',
      imagePath: 'assets/diseases/banana_yellow_sigatoka.jpg',
      severity: 'Moderate',
      treatments: 'Use a fungicide spray once a week for prevention.',
      preventiveMeasures:
          'Ensure proper spacing between plants to increase air circulation.',
    ),
    // Add more Disease instances here...
  ];

  const PlantLibrary({super.key});

  // Method to get disease by name for consistency across screens
  static Disease? getDiseaseByName(String name) {
    return diseases.firstWhereOrNull(
      (disease) => disease.name.toLowerCase() == name.toLowerCase(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: diseases.length,
      itemBuilder: (context, index) {
        final disease = diseases[index];
        return ListTile(
          leading: Image.asset(
            disease.imagePath,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
          title: Text(disease.name),
          subtitle: Text(disease.description),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            // Navigate to DiseaseDetails with all info
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiseaseDetails(
                  diseaseName: disease.name,
                  imagePath: disease.imagePath,
                  severity: disease.severity,
                  treatments: disease.treatments,
                  preventiveMeasures: disease.preventiveMeasures,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class Disease {
  final String name;
  final String description;
  final String imagePath;
  final String severity;
  final String treatments;
  final String preventiveMeasures;

  Disease({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.severity,
    required this.treatments,
    required this.preventiveMeasures,
  });
}
