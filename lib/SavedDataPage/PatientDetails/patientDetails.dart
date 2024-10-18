import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare/SavedDataPage/PatientDetails/editPatientPage.dart';

class PatientDetailsPage extends StatefulWidget {
  final String patientId;

  const PatientDetailsPage({
    Key? key,
    required this.patientId,
  }) : super(key: key);

  @override
  _PatientDetailsPageState createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  late DocumentSnapshot patientData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatientDetails();
  }

  Future<void> _fetchPatientDetails() async {
    try {
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

  void _navigateToEditPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPatientPage(
          patientId: widget.patientId,
          patientData: patientData,
        ),
      ),
    ).then((_) {
      // Refresh the patient details after returning from the edit page
      _fetchPatientDetails();
    });
  }

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
          'Patient Details',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEditPage,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailCard(
                        'Patient Name', patientData['patientName']),
                    const SizedBox(height: 10),
                    _buildDetailCard('Date', patientData['date']),
                    const SizedBox(height: 10),
                    _buildDetailCard('Age', patientData['age'].toString()),
                    const SizedBox(height: 10),
                    _buildDetailCard(
                        'Doctor Consulted', patientData['doctorConsulted']),
                    const SizedBox(height: 10),
                    const Text(
                      'Medicines:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    _buildMedicineList(patientData['medicines']),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDetailCard(String title, String content) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              content,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

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
          .map((medicine) => Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '- $medicine',
                  style: const TextStyle(fontSize: 16),
                ),
              ))
          .toList(),
    );
  }
}
