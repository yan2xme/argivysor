// plant_library.dart
import 'package:flutter/material.dart';
import 'disease_detail.dart';
import 'package:collection/collection.dart'; // For firstWhereOrNull

class PlantLibrary extends StatefulWidget {
  const PlantLibrary({super.key});

  @override
  PlantLibraryState createState() => PlantLibraryState();
}

class PlantLibraryState extends State<PlantLibrary> {
  String searchQuery = '';

  // Centralized disease data list moved to DiseaseRepository
  List<Disease> get diseases => DiseaseRepository.diseases;

  List<Disease> get filteredDiseases {
    if (searchQuery.isEmpty) {
      return diseases;
    } else {
      return diseases
          .where((disease) =>
              disease.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title and smiley face
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "Plant is Life",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SFProDisplay',
                ),
              ),
              SizedBox(height: 4),
              Text(
                ":)",
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Colors.green), // Green outline for search bar
              ),
            ),
          ),
        ),
        const SizedBox(height: 16), // Space between search bar and list
        // List of diseases
        Expanded(
          child: ListView.builder(
            itemCount: filteredDiseases.length,
            itemBuilder: (context, index) {
              final disease = filteredDiseases[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  elevation: 2,
                  color: Colors.green, // Green background for card
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.green, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          bottomLeft: Radius.circular(12.0),
                        ),
                        child: Stack(
                          children: [
                            Image.asset(
                              disease.imagePath,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.error, size: 100);
                              },
                            ),
                            Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors
                                        .green, // Green gradient to blend with card background
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  stops: [
                                    0.5,
                                    1.0
                                  ], // Increase feather effect to make it blend seamlessly
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: Text(
                            disease.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors
                                  .white, // White text for better contrast on green background
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward,
                              color: Colors
                                  .white), // White arrow icon for contrast
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal:
                                  16.0), // Uniform padding for all items
                          onTap: () {
                            // Navigate to DiseaseDetails with bullet points
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DiseaseDetails(
                                  disease: disease,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Disease model class
class Disease {
  final String name;
  final String imagePath;
  final String severity;
  final List<String> treatments; // Changed from String to List<String>
  final List<String> preventiveMeasures; // Changed from String to List<String>
  final String description; // Moved description here for DiseaseDetails

  Disease({
    required this.name,
    required this.imagePath,
    required this.severity,
    required this.treatments,
    required this.preventiveMeasures,
    required this.description,
  });
}

// DiseaseRepository for centralized data and retrieval
class DiseaseRepository {
  static final List<Disease> diseases = [
    // Banana Diseases
    Disease(
      name: 'Banana Yellow Sigatoka',
      imagePath: 'assets/diseases/banana_yellow_sigatoka.jpg',
      severity: 'Moderate',
      treatments: [
        'Immediate Action: Remove affected leaves showing initial symptoms.',
        'Chemical: Light application of mancozeb.',
        'Organic: Use of neem oil spray.',
        'Biological: Apply Trichoderma species as a preventive.'
      ],
      preventiveMeasures: [
        'Prevention Tips: Space plants for better airflow.',
        'Environmental Adjustments: Reduce overhead watering to avoid prolonged leaf moisture.'
      ],
      description:
          'Yellow Sigatoka appears as faint yellow spots on the banana leaves. The spots may gradually enlarge, but most of the leaf remains green and functional. Early-stage infections have a limited effect on photosynthesis and plant health.',
    ),
    Disease(
      name: 'Banana Cordana',
      imagePath: 'assets/diseases/banana_cordana.jpg',
      severity: 'Moderate',
      treatments: [
        'Immediate Action: Remove affected lower leaves and monitor regularly.',
        'Chemical: Apply a light dose of copper-based fungicides.',
        'Organic: Use neem oil to control early-stage fungal growth.',
        'Biological: Introduce Trichoderma as a biocontrol agent.'
      ],
      preventiveMeasures: [
        'Prevention Tips: Ensure proper spacing between plants to prevent the spread of spores.',
        'Environmental Adjustments: Avoid overwatering and keep leaves dry to limit fungal activity.'
      ],
      description:
          'Banana Cordana presents as small yellowish spots on lower banana leaves. The plant may exhibit early signs of stress but overall growth remains relatively unaffected.',
    ),
    Disease(
      name: 'Banana Healthy',
      imagePath: 'assets/diseases/banana_healthy.jpg',
      severity: 'None',
      treatments: ['No treatment required as the plant is healthy.'],
      preventiveMeasures: [
        'Maintain good soil nutrition and watering habits to keep the plant healthy.'
      ],
      description:
          'This image represents a healthy banana plant with no visible signs of disease or insect infestation. Leaves are green, well-formed, and free of spots or discoloration.',
    ),
    Disease(
      name: 'Banana Insect Pest',
      imagePath: 'assets/diseases/banana_insect_pest.jpg',
      severity: 'High',
      treatments: [
        'Chemical: Use insecticides such as imidacloprid or permethrin.',
        'Organic: Use neem oil or insecticidal soap to manage mealybugs.',
        'Mechanical: Manually remove visible pests and their eggs.'
      ],
      preventiveMeasures: [
        'Regular Monitoring: Inspect plants frequently for early signs of pests.',
        'Biological Control: Introduce natural predators like ladybugs to reduce pest population.'
      ],
      description:
          'Banana plants can be affected by several insect pests, such as aphids, weevils, and beetles, which cause visible damage to the leaves and fruit, often leading to stunted growth or reduced yield.',
    ),
    Disease(
      name: 'Banana Moko',
      imagePath: 'assets/diseases/banana_moko.jpg',
      severity: 'High',
      treatments: [
        'Immediate Action: Remove and destroy affected plants to prevent spread.',
        'Chemical: There is no effective chemical treatment for Moko disease.',
        'Hygiene: Disinfect tools to avoid cross-contamination.'
      ],
      preventiveMeasures: [
        'Use disease-free planting material.',
        'Avoid planting bananas in fields where Moko has previously occurred.'
      ],
      description:
          'Moko disease is caused by a bacterial infection that affects banana plants, leading to wilting, yellowing of leaves, and internal discoloration of the pseudostem. It spreads rapidly and can devastate entire plantations.',
    ),
    Disease(
      name: 'Banana Mosaic',
      imagePath: 'assets/diseases/banana_mosaic.jpg',
      severity: 'Moderate',
      treatments: [
        'Immediate Action: Remove and destroy infected plants.',
        'Chemical: No direct chemical treatment available for viral diseases.',
        'Hygiene: Control aphid population as they are vectors of the virus.'
      ],
      preventiveMeasures: [
        'Use certified virus-free planting material.',
        'Monitor and control aphid populations to prevent virus spread.'
      ],
      description:
          'Banana Mosaic Virus causes mottled and streaked patterns on banana leaves, leading to reduced photosynthesis and potentially lower yields if not managed properly.',
    ),
    Disease(
      name: 'Banana Panama',
      imagePath: 'assets/diseases/banana_panama.jpg',
      severity: 'High',
      treatments: [
        'Immediate Action: Remove infected plants and destroy them.',
        'Chemical: There is no chemical cure for Panama disease.',
        'Soil Management: Avoid waterlogging as it can worsen the spread of the disease.'
      ],
      preventiveMeasures: [
        'Use disease-resistant banana varieties.',
        'Rotate crops to avoid soil buildup of the pathogen.'
      ],
      description:
          'Panama disease, also known as Fusarium wilt, affects banana plants by causing the leaves to yellow and wilt, eventually killing the plant. It is caused by a soil-borne fungus and is highly destructive.',
    ),

    // Coconut Diseases
    Disease(
      name: 'Coconut Bud Root Dropping',
      imagePath: 'assets/diseases/coconut_bud_root_dropping.jpg',
      severity: 'High',
      treatments: [
        'Immediate Action: Trim affected roots to prevent further dropping.',
        'Chemical: Apply fungicides to treat root infections.',
        'Cultural: Improve soil drainage and reduce waterlogging.'
      ],
      preventiveMeasures: [
        'Use well-drained soil to prevent root diseases.',
        'Regularly inspect roots for early signs of infection.'
      ],
      description:
          'Coconut Bud Root Dropping is characterized by the loss of young roots and buds, leading to weakened plant structure and reduced nutrient uptake. This can severely impact the overall health and productivity of the coconut palm.',
    ),
    Disease(
      name: 'Coconut Bud Rot',
      imagePath: 'assets/diseases/coconut_bud_rot.jpg',
      severity: 'High',
      treatments: [
        'Immediate Action: Remove and destroy affected buds and young leaves.',
        'Chemical: Apply copper-based fungicides to prevent the spread.',
        'Hygiene: Ensure tools are disinfected when working on infected plants.'
      ],
      preventiveMeasures: [
        'Avoid planting in waterlogged areas.',
        'Use resistant coconut varieties if available.'
      ],
      description:
          'Coconut Bud Rot affects the youngest parts of the coconut palm, causing wilting and death of new shoots. If left unchecked, it can lead to the death of the entire palm.',
    ),
    Disease(
      name: 'Coconut Catterpillar',
      imagePath: 'assets/diseases/coconut_catterpillar.jpg',
      severity: 'Moderate',
      treatments: [
        'Chemical: Apply appropriate insecticides targeting caterpillars.',
        'Organic: Use biological pesticides like Bacillus thuringiensis (Bt).',
        'Mechanical: Manually remove caterpillars from the palms.'
      ],
      preventiveMeasures: [
        'Regularly inspect palms for early signs of caterpillar infestation.',
        'Maintain plant hygiene to reduce pest habitats.'
      ],
      description:
          'Coconut Catterpillars are larvae that feed on coconut leaves, causing significant defoliation and weakening the palm. Severe infestations can reduce coconut yield and overall plant vigor.',
    ),
    Disease(
      name: 'Coconut Catterpillar Spot',
      imagePath: 'assets/diseases/coconut_catterpillar_spot.jpg',
      severity: 'Moderate',
      treatments: [
        'Chemical: Use insecticides to control caterpillar populations.',
        'Organic: Introduce natural predators like birds or beneficial insects.',
        'Mechanical: Prune affected areas to limit spread.'
      ],
      preventiveMeasures: [
        'Implement integrated pest management (IPM) strategies.',
        'Ensure proper nutrition to enhance plant resistance.'
      ],
      description:
          'Coconut Catterpillar Spot refers to the damage and spots caused by caterpillar feeding on coconut leaves. This can lead to reduced photosynthetic area and increased susceptibility to other diseases.',
    ),
    Disease(
      name: 'Coconut Grayleaf Spot',
      imagePath: 'assets/diseases/coconut_grayleaf_spot.jpg',
      severity: 'Moderate',
      treatments: [
        'Chemical: Apply fungicides containing chlorothalonil or copper-based solutions.',
        'Organic: Use neem oil sprays to control fungal growth.',
        'Cultural: Remove and destroy infected leaves to prevent spread.'
      ],
      preventiveMeasures: [
        'Ensure good air circulation around the palms.',
        'Avoid overhead irrigation to reduce leaf moisture.'
      ],
      description:
          'Grayleaf Spot is a fungal disease that causes grayish spots on coconut leaves. Over time, these spots can coalesce, leading to significant leaf damage and reduced photosynthetic capability.',
    ),
    Disease(
      name: 'Coconut Leaf Rot',
      imagePath: 'assets/diseases/coconut_leaf_rot.jpg',
      severity: 'High',
      treatments: [
        'Immediate Action: Remove and destroy severely infected leaves.',
        'Chemical: Apply systemic fungicides to affected areas.',
        'Cultural: Remove and destroy infected plant material to prevent spread.'
      ],
      preventiveMeasures: [
        'Maintain proper drainage to avoid waterlogging.',
        'Use disease-resistant coconut varieties.'
      ],
      description:
          'Coconut Leaf Rot is characterized by the decay and eventual death of coconut leaves. The disease impairs the plant’s ability to photosynthesize effectively, leading to reduced growth and productivity.',
    ),
    Disease(
      name: 'Coconut Stem Bleeding',
      imagePath: 'assets/diseases/coconut_stem_bleeding.jpg',
      severity: 'High',
      treatments: [
        'Immediate Action: Clean the bleeding areas to prevent secondary infections.',
        'Chemical: Apply appropriate fungicides to control underlying infections.',
        'Cultural: Improve soil health and reduce plant stress.'
      ],
      preventiveMeasures: [
        'Ensure proper fertilization to maintain plant strength.',
        'Avoid physical injuries to the stem during maintenance.'
      ],
      description:
          'Stem Bleeding in coconut palms is often a sign of internal damage or infection. It can lead to the weakening of the stem structure and make the plant more susceptible to breakage and other diseases.',
    ),
    Disease(
      name: 'Coconut Fruit Healthy',
      imagePath: 'assets/diseases/coconut_fruit_healthy.jpg',
      severity: 'None',
      treatments: ['No treatment required as the fruit is healthy.'],
      preventiveMeasures: [
        'Maintain good cultivation practices to ensure fruit health.',
        'Regularly monitor for any signs of pests or diseases.'
      ],
      description:
          'This image represents a healthy coconut fruit, free from any signs of disease or pest infestation. The fruit is well-formed, with a strong husk and no discoloration.',
    ),
    Disease(
      name: 'Coconut Fruit Infected',
      imagePath: 'assets/diseases/coconut_fruit_infected.jpg',
      severity: 'High',
      treatments: [
        'Immediate Action: Remove and destroy infected fruits to prevent spread.',
        'Chemical: Apply appropriate fungicides to control rot-causing pathogens.',
        'Hygiene: Sanitize harvesting tools to prevent cross-contamination.'
      ],
      preventiveMeasures: [
        'Implement proper harvesting techniques to minimize fruit damage.',
        'Ensure good air circulation around the fruiting areas.'
      ],
      description:
          'Infected coconut fruits show signs of rot, discoloration, and may have fungal growth. Infections can lead to significant yield losses and affect the overall quality of the harvest.',
    ),

    // Corn Diseases
    Disease(
      name: 'Corn Cercospora Leaf Spot',
      imagePath: 'assets/diseases/corn_cercospora_leaf_spot.jpg',
      severity: 'Moderate',
      treatments: [
        'Chemical: Use fungicides containing azoxystrobin or propiconazole.',
        'Organic: Apply neem oil during early infection stages.',
        'Cultural: Rotate crops to avoid buildup of the pathogen.'
      ],
      preventiveMeasures: [
        'Use disease-free seed.',
        'Avoid overhead irrigation to reduce leaf wetness.'
      ],
      description:
          'Cercospora Leaf Spot appears as small, dark lesions on corn leaves. Over time, these spots enlarge and coalesce, leading to significant leaf area loss and reduced photosynthesis.',
    ),
    Disease(
      name: 'Corn Common Rust',
      imagePath: 'assets/diseases/corn_common_rust.jpg',
      severity: 'Moderate',
      treatments: [
        'Chemical: Apply fungicides containing triazoles or strobilurins.',
        'Organic: Use copper-based fungicides as an alternative.',
        'Cultural: Implement crop rotation and remove infected debris.'
      ],
      preventiveMeasures: [
        'Plant resistant corn varieties.',
        'Ensure proper spacing to enhance airflow around plants.'
      ],
      description:
          'Common Rust is characterized by reddish-brown pustules on the upper surfaces of corn leaves. Severe infections can lead to defoliation and reduced grain yield.',
    ),
    Disease(
      name: 'Corn Healthy',
      imagePath: 'assets/diseases/corn_healthy.jpg',
      severity: 'None',
      treatments: ['No treatment required as the plant is healthy.'],
      preventiveMeasures: [
        'Maintain optimal soil fertility and moisture levels.',
        'Regularly monitor for any signs of pests or diseases.'
      ],
      description:
          'This image represents a healthy corn plant with vibrant green leaves and no visible signs of disease or pest infestation. The plant is robust and exhibits normal growth patterns.',
    ),
    Disease(
      name: 'Corn Northern Leaf Blight',
      imagePath: 'assets/diseases/corn_northern_leaf_blight.jpg',
      severity: 'High',
      treatments: [
        'Chemical: Apply fungicides containing chlorothalonil or mancozeb.',
        'Organic: Use sulfur-based fungicides to control fungal pathogens.',
        'Cultural: Remove and destroy infected plant debris.'
      ],
      preventiveMeasures: [
        'Use resistant corn varieties.',
        'Ensure adequate spacing for better air circulation around plants.'
      ],
      description:
          'Northern Leaf Blight causes elongated grayish lesions with a characteristic funnel shape on corn leaves. The disease can lead to significant yield losses by reducing the photosynthetic capacity of the plant.',
    ),

    // Pineapple Diseases
    Disease(
      name: 'Pineapple Crown Rot',
      imagePath: 'assets/diseases/pineapple_crown_rot.jpg',
      severity: 'High',
      treatments: [
        'Immediate Action: Remove and destroy affected crowns.',
        'Chemical: Apply fungicides to control fungal pathogens.',
        'Hygiene: Disinfect tools and equipment to prevent spread.'
      ],
      preventiveMeasures: [
        'Ensure proper drainage in planting areas.',
        'Use disease-free planting material.'
      ],
      description:
          'Pineapple Crown Rot is a fungal disease that affects the central crown of the pineapple plant. It leads to the decay of the crown, inhibiting new shoot growth and potentially killing the plant.',
    ),
    Disease(
      name: 'Pineapple Fruit Fasciation',
      imagePath: 'assets/diseases/pineapple_fruit_fasciation.jpg',
      severity: 'Moderate',
      treatments: [
        'Immediate Action: Remove affected fruits to prevent spread.',
        'Chemical: No specific chemical treatments; focus on cultural practices.',
        'Cultural: Ensure proper nutrient management to support healthy growth.'
      ],
      preventiveMeasures: [
        'Use disease-free planting material.',
        'Maintain optimal growing conditions to prevent stress-related fasciation.'
      ],
      description:
          'Fruit Fasciation in pineapples results in abnormal, flattened, or elongated fruit structures. While not always harmful, it can affect the marketability and quality of the fruit.',
    ),
    Disease(
      name: 'Pineapple Fruit Rot',
      imagePath: 'assets/diseases/pineapple_fruit_rot.jpg',
      severity: 'High',
      treatments: [
        'Immediate Action: Remove and destroy infected fruits.',
        'Chemical: Apply appropriate fungicides to control rot-causing pathogens.',
        'Hygiene: Sanitize harvesting tools to prevent cross-contamination.'
      ],
      preventiveMeasures: [
        'Ensure proper spacing for adequate airflow.',
        'Avoid waterlogging and excessive moisture around the fruit.'
      ],
      description:
          'Pineapple Fruit Rot is caused by various fungal pathogens that lead to the decay and deterioration of the fruit. Infected fruits become soft, discolored, and unsuitable for consumption or sale.',
    ),
    Disease(
      name: 'Pineapple Healthy',
      imagePath: 'assets/diseases/pineapple_healthy.jpg',
      severity: 'None',
      treatments: ['No treatment required as the pineapple is healthy.'],
      preventiveMeasures: [
        'Maintain optimal soil fertility and irrigation practices.',
        'Regularly inspect plants for any signs of pests or diseases.'
      ],
      description:
          'This image represents a healthy pineapple plant with vibrant green leaves and mature, undamaged fruits. The plant is thriving under proper cultivation conditions.',
    ),
    Disease(
      name: 'Pineapple Mealybug Wilt',
      imagePath: 'assets/diseases/pineapple_mealybug_wilt.jpg',
      severity: 'High',
      treatments: [
        'Chemical: Apply systemic insecticides to control mealybug populations.',
        'Organic: Use neem oil or insecticidal soaps to manage mealybugs.',
        'Biological: Introduce natural predators like lady beetles or parasitic wasps.'
      ],
      preventiveMeasures: [
        'Regularly monitor plants for early signs of mealybug infestation.',
        'Maintain plant hygiene to reduce pest habitats.'
      ],
      description:
          'Mealybug Wilt is caused by mealybug infestations that suck sap from pineapple plants, leading to wilting, stunted growth, and reduced fruit yield. Severe infestations can kill the plant.',
    ),
    Disease(
      name: 'Pineapple Multiple Crop Disorder',
      imagePath: 'assets/diseases/pineapple_multiple_crop_disorder.jpg',
      severity: 'Moderate',
      treatments: [
        'Chemical: Apply balanced fertilizers to support plant health.',
        'Cultural: Implement crop rotation to reduce disease pressure.',
        'Hygiene: Remove and destroy any diseased plant material.'
      ],
      preventiveMeasures: [
        'Ensure proper nutrient management.',
        'Maintain optimal irrigation practices to avoid plant stress.'
      ],
      description:
          'Multiple Crop Disorder in pineapples refers to a combination of various physiological and nutritional issues that affect plant growth and fruit development. Proper management can mitigate these disorders.',
    ),
    Disease(
      name: 'Pineapple Root Rot',
      imagePath: 'assets/diseases/pineapple_root_rot.jpg',
      severity: 'High',
      treatments: [
        'Immediate Action: Remove and destroy affected plants to prevent spread.',
        'Chemical: Apply fungicides to soil to control root pathogens.',
        'Cultural: Improve soil drainage and reduce waterlogging.'
      ],
      preventiveMeasures: [
        'Use well-drained soil and avoid overwatering.',
        'Implement crop rotation with non-host plants.'
      ],
      description:
          'Pineapple Root Rot is caused by soil-borne fungi that infect the roots, leading to decay and impaired nutrient uptake. Infected plants exhibit reduced vigor and may eventually die if not managed.',
    ),

    // Sugarcane Diseases
    Disease(
      name: 'Sugarcane Healthy',
      imagePath: 'assets/diseases/sugarcane_healthy.jpg',
      severity: 'None',
      treatments: ['No treatment required as the sugarcane is healthy.'],
      preventiveMeasures: [
        'Maintain proper soil fertility and irrigation.',
        'Regularly inspect fields for any signs of pests or diseases.'
      ],
      description:
          'This image represents healthy sugarcane plants with vibrant green leaves and robust stalks. The plants are free from any visible signs of disease or pest infestation.',
    ),
    Disease(
      name: 'Sugarcane Mosaic Virus',
      imagePath: 'assets/diseases/sugarcane_mosaic_virus.jpg',
      severity: 'Moderate',
      treatments: [
        'Immediate Action: Remove infected plants to prevent virus spread.',
        'Chemical: No direct chemical treatment for viral infections.',
        'Hygiene: Control aphid vectors that spread the virus.'
      ],
      preventiveMeasures: [
        'Use certified virus-free planting material.',
        'Control aphid populations to prevent virus spread.'
      ],
      description:
          'Sugarcane Mosaic Virus causes mosaic-like discoloration on sugarcane leaves, leading to stunted growth and reduced yields. The disease is spread primarily by aphids and can significantly impact crop productivity.',
    ),
    Disease(
      name: 'Sugarcane Red Rot',
      imagePath: 'assets/diseases/sugarcane_red_rot.jpg',
      severity: 'High',
      treatments: [
        'Immediate Action: Remove and destroy affected canes.',
        'Chemical: Treat soil with fungicides to prevent further spread.',
        'Cultural: Avoid waterlogging and maintain proper drainage.'
      ],
      preventiveMeasures: [
        'Use resistant varieties of sugarcane.',
        'Ensure good field sanitation and crop rotation.'
      ],
      description:
          'Red Rot is a fungal disease that affects the internal tissues of sugarcane, causing reddening and a foul odor. It is highly destructive and can cause significant yield losses if not managed properly.',
    ),
    Disease(
      name: 'Sugarcane Rust',
      imagePath: 'assets/diseases/sugarcane_rust.jpg',
      severity: 'Moderate',
      treatments: [
        'Chemical: Apply fungicides containing chlorothalonil or mancozeb.',
        'Cultural: Remove heavily infected leaves to prevent spore spread.',
        'Organic: Use sulfur-based sprays as a preventive.'
      ],
      preventiveMeasures: [
        'Plant resistant varieties of sugarcane.',
        'Avoid overhead irrigation to reduce leaf moisture.'
      ],
      description:
          'Sugarcane Rust appears as reddish-brown pustules on the leaves, leading to premature leaf drop and reduced photosynthetic capability. It thrives in humid environments with prolonged leaf wetness.',
    ),
    Disease(
      name: 'Sugarcane Yellow',
      imagePath: 'assets/diseases/sugarcane_yellow.jpg',
      severity: 'Moderate',
      treatments: [
        'No chemical treatment is available; focus on cultural practices.',
        'Remove symptomatic leaves to reduce disease load.',
        'Ensure plants have adequate nutrition, especially potassium.'
      ],
      preventiveMeasures: [
        'Plant resistant varieties if available.',
        'Control aphid populations as they are vectors of the disease.'
      ],
      description:
          'Sugarcane Yellow Leaf Syndrome causes yellowing of the midrib and can spread slowly throughout the plant. While it generally has a mild impact, in severe cases, it can lead to reduced plant vigor and lower yields.',
    ),
    // Add more Disease instances as needed...
  ];

  // Method to retrieve a disease by name (case-insensitive)
  static Disease? getDiseaseByName(String detectedDisease) {
    return diseases.firstWhereOrNull((disease) =>
        disease.name.toLowerCase() == detectedDisease.toLowerCase());
  }
}
