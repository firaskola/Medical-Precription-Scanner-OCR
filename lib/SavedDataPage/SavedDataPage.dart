import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicare/SavedDataPage/PatientCard.dart';
import 'package:medicare/AddPatients/AddPatientPage.dart';
import 'package:medicare/SavedDataPage/PatientDetails/patientDetails.dart'; // Import PatientDetails page

class SavedDataPage extends StatefulWidget {
  const SavedDataPage({super.key});

  @override
  _SavedDataPageState createState() => _SavedDataPageState();
}

class _SavedDataPageState extends State<SavedDataPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).primaryColorLight,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(CupertinoIcons.chevron_back),
        ),
        title: const Text(
          'Saved Data',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final newPatient = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddPatientPage(),
                ),
              );

              if (newPatient != null) {
                await _deletePatientsWithAgeZero();
                setState(() {}); // Refresh the page after adding a new patient
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getPatientsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No data available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          final patients = snapshot.data!.docs;
          final validPatients = patients.where((patientDoc) {
            final patientData = patientDoc.data() as Map<String, dynamic>;
            final patientName = patientData['patientName'];
            return patientName != null && patientName.isNotEmpty;
          }).toList();

          if (validPatients.isEmpty) {
            return const Center(
              child: Text(
                'No data available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: validPatients.length,
                  itemBuilder: (context, index) {
                    final patientDoc = validPatients[index];
                    final patientData =
                        patientDoc.data() as Map<String, dynamic>;

                    final patientName = patientData['patientName'];
                    final date = patientData['date'];
                    final doctorConsulted = patientData['doctorConsulted'];
                    int age = 0;

                    if (patientData['age'] != null) {
                      if (patientData['age'] is int) {
                        age = patientData['age'];
                      } else if (patientData['age'] is String) {
                        age = int.tryParse(patientData['age']) ?? 0;
                      }
                    }

                    return PatientCard(
                      patientName: patientName,
                      date: date ?? 'No Date',
                      age: age,
                      doctorConsulted: doctorConsulted ?? 'No Doctor',
                      onTap: () {
                        // Navigate to PatientDetails page with the selected patient's ID
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PatientDetailsPage(
                              patientId:
                                  patientDoc.id, // Pass the patient ID here
                            ),
                          ),
                        );
                      },
                      onClose: () async {
                        await _deletePatient(patientDoc.id);
                        setState(() {});
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> _getPatientsStream() {
    final user = _auth.currentUser;
    if (user != null) {
      // Correct the path: patients directly under the user's document
      return _firestore
          .collection('Medicare')
          .doc('users')
          .collection('users')
          .doc(user.uid)
          .collection('patients')
          .snapshots();
    } else {
      return const Stream.empty();
    }
  }

  Future<void> _deletePatientsWithAgeZero() async {
    final user = _auth.currentUser;
    if (user != null) {
      final patientsWithAgeZero = await _firestore
          .collection('Medicare')
          .doc('users')
          .collection('users')
          .doc(user.uid)
          .collection('patients')
          .where('age', isEqualTo: 0)
          .get();

      for (var doc in patientsWithAgeZero.docs) {
        await doc.reference.delete();
      }
    }
  }

  Future<void> _deletePatient(String patientId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('Medicare')
          .doc('users')
          .collection('users')
          .doc(user.uid)
          .collection('patients')
          .doc(patientId)
          .delete();
    }
  }
}
