import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientDetailsPage extends StatefulWidget {
  final String patientId; // Pass the patient ID from Firebase

  const PatientDetailsPage({
    Key? key,
    required this.patientId, // Add patientId to fetch from Firestore
  }) : super(key: key);

  @override
  _PatientDetailsPageState createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  late DocumentSnapshot patientData; // To store the patient data from Firebase
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatientDetails();
  }

  Future<void> _fetchPatientDetails() async {
    try {
      // Fetch the patient document from Firebase using the patient ID
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Medicare')
          .doc('users')
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('patients')
          .doc(widget.patientId)
          .get();

      setState(() {
        patientData = doc;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching patient data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Loading state
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patient Name: ${patientData['patientName']}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Date: ${patientData['date']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Age: ${patientData['age']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Doctor Consulted: ${patientData['doctorConsulted']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Medicines:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    _buildMedicineList(patientData['medicines']),
                  ],
                ),
              ),
            ),
    );
  }

  // Method to display the list of medicines
  Widget _buildMedicineList(List<dynamic> medicines) {
    if (medicines.isEmpty) {
      return const Text(
        'No medicines provided.',
        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: medicines
          .map((medicine) => Text(
                '- $medicine',
                style: const TextStyle(fontSize: 16),
              ))
          .toList(),
    );
  }
}
