import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicare/SavedDataPage/PatientCard.dart';
import 'package:medicare/AddPatients/AddPatientPage.dart';

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

          // If there's no data or the data is empty, show the message
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

          // Filter patients to ensure only valid entries are displayed
          final validPatients = patients.where((patientDoc) {
            final patientData = patientDoc.data() as Map<String, dynamic>;
            final patientName = patientData['patientName'];
            return patientName != null && patientName.isNotEmpty;
          }).toList();

          // Check if there are valid patients after filtering
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
                  shrinkWrap:
                      true, // Allows ListView to occupy only needed space
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: validPatients.length,
                  itemBuilder: (context, index) {
                    final patientData =
                        validPatients[index].data() as Map<String, dynamic>;

                    // Safely retrieve each field
                    final patientName = patientData['patientName'];
                    final date = patientData['date'];
                    final doctorConsulted = patientData['doctorConsulted'];

                    // Handle age field to ensure it's an integer
                    int age = 0; // Default value
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
                        print('Patient card tapped for $patientName!');
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
}
