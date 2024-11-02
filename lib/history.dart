import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert'; // For JSON encoding/decoding
import 'package:intl/intl.dart'; // For date formatting and comparison
import 'detection_result.dart'; // To redirect back to DetectionResult
import 'dart:developer' as devtools; // For logging

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, String>> inferenceHistory = [];
  String sortOption = 'chronological'; // Default sort option
  bool _isSaving = false; // Flag to prevent double-saving

  @override
  void initState() {
    super.initState();
    _loadHistory(); // Load history when the page is opened
  }

  // Load the inference history from local storage
  Future<void> _loadHistory() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/inference_history.json');

    if (await file.exists()) {
      final contents = await file.readAsString();
      List<dynamic> historyData = jsonDecode(contents);

      setState(() {
        inferenceHistory = historyData.map((e) {
          return Map<String, String>.from(
              e); // Convert dynamic to Map<String, String>
        }).toList();
      });
    }
  }

  // Function to save only the highest accuracy for each disease (once)
  Future<void> _saveInference(Map<String, String> newInference) async {
    if (_isSaving) {
      return; // Prevent re-entry if already saving
    }

    _isSaving = true; // Mark that saving has started

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/inference_history.json');

    // Load existing history if the file exists
    if (await file.exists()) {
      final contents = await file.readAsString();
      List<dynamic> historyData = jsonDecode(contents);

      setState(() {
        inferenceHistory = historyData.map((e) {
          return Map<String, String>.from(e);
        }).toList();
      });
    }

    // Check if the same inference already exists
    bool isDuplicate = false;
    for (var entry in inferenceHistory) {
      if (entry['diseaseName'] == newInference['diseaseName'] &&
          entry['accuracy'] == newInference['accuracy'] &&
          entry['imagePath'] == newInference['imagePath'] &&
          entry['date'] == newInference['date']) {
        isDuplicate = true;
        break;
      }
    }

    if (!isDuplicate) {
      // Check if a record for the same disease already exists
      bool found = false;
      for (var entry in inferenceHistory) {
        if (entry['diseaseName'] == newInference['diseaseName']) {
          found = true;
          double existingAccuracy = double.parse(entry['accuracy']!);
          double newAccuracy = double.parse(newInference['accuracy']!);

          // Replace with the new inference only if the accuracy is higher
          if (newAccuracy > existingAccuracy) {
            entry['accuracy'] = newInference['accuracy']!;
            entry['imagePath'] = newInference['imagePath']!;
            entry['date'] = newInference['date']!;
          }
          break;
        }
      }

      // If no existing entry is found, add the new inference
      if (!found) {
        inferenceHistory.add(newInference);
      }

      // Save the updated history back to the file
      String data = jsonEncode(inferenceHistory);
      await file.writeAsString(data);

      devtools.log("Inference saved: $data"); // Log for debugging
    } else {
      devtools.log(
          "Duplicate inference detected, not saving."); // Log for debugging
    }

    _isSaving = false; // Mark that saving has ended
  }

  // Function to group the inferences into Today, Yesterday, and Older
  String _groupByDate(String date) {
    final DateTime inferenceDate = DateTime.parse(date);
    final DateTime now = DateTime.now();
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');

    if (dateFormatter.format(inferenceDate) == dateFormatter.format(now)) {
      return 'Today';
    } else if (dateFormatter.format(inferenceDate) ==
        dateFormatter.format(now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM dd, yyyy').format(inferenceDate);
    }
  }

  // Function to clear the entire history
  Future<void> _clearHistory() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/inference_history.json');

    if (await file.exists()) {
      await file.delete(); // Delete the file
      setState(() {
        inferenceHistory.clear(); // Clear the in-memory list
      });
    }
  }

  // Confirmation dialog before clearing the history
  Future<void> _showClearConfirmation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Must be tapped explicitly
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Inference History'),
          content: const Text(
              'Are you sure you want to clear all inferences? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog without clearing
              },
            ),
            TextButton(
              child: const Text('Clear'),
              onPressed: () {
                _clearHistory(); // Clear the history
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Sort Button UI and functionality
  Widget _buildSortButton() {
    return IconButton(
      icon: const Icon(Icons.sort),
      onPressed: () {
        setState(() {
          sortOption =
              sortOption == 'chronological' ? 'alphabetical' : 'chronological';
          inferenceHistory.sort((a, b) {
            if (sortOption == 'alphabetical') {
              return a['diseaseName']!.compareTo(b['diseaseName']!);
            } else {
              return DateTime.parse(b['date']!)
                  .compareTo(DateTime.parse(a['date']!));
            }
          });
        });
      },
      tooltip: 'Sort Inferences',
    );
  }

  // Clear Button UI and functionality
  Widget _buildClearButton() {
    return IconButton(
      icon: const Icon(Icons.delete_outline),
      onPressed: _showClearConfirmation,
      tooltip: 'Clear History',
    );
  }

  @override
  Widget build(BuildContext context) {
    // Group the inferences by date
    Map<String, List<Map<String, String>>> groupedInferences = {};
    for (var item in inferenceHistory) {
      String group = _groupByDate(item['date']!);
      if (!groupedInferences.containsKey(group)) {
        groupedInferences[group] = [];
      }
      groupedInferences[group]!.add(item);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inference History'),
        actions: [
          _buildSortButton(),
          _buildClearButton(),
        ],
      ),
      body: inferenceHistory.isEmpty
          ? const Center(
              child: Text('No inferences yet!'),
            )
          : ListView(
              children: groupedInferences.keys.map((group) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: groupedInferences[group]!.map((historyItem) {
                          return GestureDetector(
                            onTap: () {
                              // Redirect back to DetectionResult when an item is tapped
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetectionResult(
                                    diseaseName: historyItem['diseaseName']!,
                                    accuracy:
                                        double.parse(historyItem['accuracy']!),
                                    imagePath: historyItem['imagePath']!,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              elevation: 3,
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.file(
                                    File(historyItem['imagePath']!),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                          Icons.image_not_supported,
                                          size: 50);
                                    },
                                  ),
                                ),
                                title: Text(
                                  historyItem['diseaseName']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Text(
                                  'Date: ${historyItem['date']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${historyItem['accuracy']}%',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 0, 173, 90),
                                      ),
                                    ),
                                    const Text(
                                      'Confidence',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}
