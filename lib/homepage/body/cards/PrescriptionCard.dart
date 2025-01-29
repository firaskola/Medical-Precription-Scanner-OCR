import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PrescriptionCard extends StatefulWidget {
  const PrescriptionCard({super.key});

  @override
  State<PrescriptionCard> createState() => _PrescriptionCardState();
}

class _PrescriptionCardState extends State<PrescriptionCard> {
  bool _isLoading = false;
  String? _outputText; // Store extracted text from API response

  // Method to pick image from gallery or camera
  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        _isLoading = true; // Show loading indicator
        _outputText = "Processing...";
      });

      try {
        final response = await _sendImageToApi(image.path);
        if (response.statusCode == 200) {
          final parsedData = jsonDecode(response.body);
          print("Response: $parsedData");

          await _uploadPatientData(parsedData);

          setState(() {
            _isLoading = false; // Hide loading indicator
            _outputText = "Processing Complete"; // Show success message
          });

// Remove the banner after 3 seconds
          Future.delayed(const Duration(seconds: 3), () {
            setState(() {
              _outputText = null;
            });
          });
        } else {
          print("Failed to upload image: ${response.body}");
          setState(() {
            _isLoading = false;
            _outputText = "Processing Failed"; // Show failure message
          });
        }
      } catch (e) {
        print("Error: $e");
        setState(() {
          _isLoading = false;
          _outputText = "Processing Failed"; // Handle errors
        });
      }
    } else {
      print('No image selected');
    }
  }

  // Send image to Flask API and get response
  Future<http.Response> _sendImageToApi(String imagePath) async {
    final Uri uri = Uri.parse(
        'https://medicare.hubzero.in/upload'); // Update with your Flask API URL
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  // Upload the patient data to Firebase Firestore
  Future<void> _uploadPatientData(Map<String, dynamic> patientData) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final patientsRef = FirebaseFirestore.instance
          .collection('Medicare')
          .doc('users')
          .collection('users')
          .doc(userId)
          .collection('patients');

      await patientsRef.add(patientData);
      print("Patient data uploaded to Firestore successfully!");
    } else {
      print("User is not logged in!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        top: 16.0,
        right: 16.0,
        bottom: 0.0,
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/4.jpg'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 24.0,
                bottom: 24.0,
                child: Text(
                  'Prescription Scanner',
                  style: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              Positioned(
                right: 16.0,
                bottom: 16.0,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: TextButton(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      backgroundColor: WidgetStateProperty.all<Color>(
                        Theme.of(context).primaryColor,
                      ),
                      foregroundColor:
                          WidgetStateProperty.all<Color>(Colors.black),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (BuildContext context) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickImage(context, ImageSource.gallery);
                                  },
                                  child: ListTile(
                                    leading: Icon(
                                      CupertinoIcons.photo,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    title: Text(
                                      'Upload Image',
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorLight,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                Divider(color: Theme.of(context).primaryColor),
                                InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickImage(context, ImageSource.camera);
                                  },
                                  child: ListTile(
                                    leading: Icon(
                                      CupertinoIcons.camera,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    title: Text(
                                      'Take Image',
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorLight,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Text(
                      'Upload Image',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).primaryColorLight,
                      ),
                    ),
                  ),
                ),
              ),

              // Loading Indicator
              if (_isLoading)
                Center(
                  child: Container(
                    //color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),

              // Display Output if API Response is Received
              if (_outputText != null)
                Positioned(
                  left: 16,
                  right: 16,
                  top: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _outputText!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
