import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PrescriptionCard extends StatelessWidget {
  const PrescriptionCard({Key? key}) : super(key: key);

  // Method to pick image from gallery or camera
  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      print("Image path: ${image.path}");
      try {
        final response = await _sendImageToApi(image.path);
        if (response.statusCode == 200) {
          final parsedData = jsonDecode(response.body);
          print("Response: $parsedData");

          // Upload the extracted data to Firestore
          await _uploadPatientData(parsedData);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    "Image uploaded successfully!\nPatient Name: ${parsedData['patient_name']}")),
          );
        } else {
          print("Failed to upload image: ${response.body}");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to upload image.")),
          );
        }
      } catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An error occurred while uploading.")),
        );
      }
    } else {
      print('No image selected');
    }
  }

  // Send image to Flask API and get response
  Future<http.Response> _sendImageToApi(String imagePath) async {
    final Uri uri = Uri.parse(
        'http://192.168.1.14:6000/upload'); // Update with your Flask API URL
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  // Upload the patient data to Firebase Firestore
  Future<void> _uploadPatientData(Map<String, dynamic> patientData) async {
    // Ensure the user is logged in
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;

      // Reference to the Firestore collection for the logged-in user
      final patientsRef = FirebaseFirestore.instance
          .collection('Medicare')
          .doc('users')
          .collection('users')
          .doc(userId)
          .collection('patients');

      // Add new patient document with extracted data
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
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).primaryColor,
                      ),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.black),
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
                                    _pickImage(context, ImageSource.gallery);
                                    Navigator.pop(context);
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
                                    _pickImage(context, ImageSource.camera);
                                    Navigator.pop(context);
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
            ],
          ),
        ),
      ),
    );
  }
}
