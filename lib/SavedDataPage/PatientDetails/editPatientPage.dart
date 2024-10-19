import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditPatientPage extends StatefulWidget {
  final String patientId;
  final DocumentSnapshot patientData;

  const EditPatientPage({
    super.key,
    required this.patientId,
    required this.patientData,
  });

  @override
  _EditPatientPageState createState() => _EditPatientPageState();
}

class _EditPatientPageState extends State<EditPatientPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<TextEditingController> medicineControllers = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController doctorController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.patientData['patientName'];
    ageController.text = widget.patientData['age'].toString();
    doctorController.text = widget.patientData['doctorConsulted'];
    dateController.text = widget.patientData['date'];

    // Initialize medicine controllers
    List<String> medicines = List<String>.from(widget.patientData['medicines']);
    for (var medicine in medicines) {
      medicineControllers.add(TextEditingController(text: medicine));
    }
  }

  @override
  void dispose() {
    // Dispose of all controllers
    for (var controller in medicineControllers) {
      controller.dispose();
    }
    nameController.dispose();
    ageController.dispose();
    doctorController.dispose();
    dateController.dispose();
    super.dispose();
  }

  void addMedicineField() {
    if (medicineControllers.length < 5) {
      setState(() {
        medicineControllers.add(TextEditingController());
      });
    }
  }

  Future<void> submitPatientData() async {
    if (isLoading) return; // Prevent multiple submissions
    setState(() {
      isLoading = true;
    });

    final User? user = _auth.currentUser;

    if (user != null) {
      // Prepare data to be stored in Firestore
      Map<String, dynamic> patientData = {
        'patientName': nameController.text,
        'age': int.tryParse(ageController.text) ?? 0,
        'doctorConsulted': doctorController.text,
        'date': dateController.text,
        'medicines':
            medicineControllers.map((controller) => controller.text).toList(),
      };

      try {
        // Update the data in Firestore under the current user's collection
        await _firestore
            .collection('Medicare')
            .doc('users')
            .collection('users')
            .doc(user.uid)
            .collection('patients')
            .doc(widget.patientId)
            .update(patientData);

        print('Data updated successfully, returning to previous page');
        Navigator.pop(context, patientData);
      } catch (e) {
        // Log error if saving fails
        print("Error updating patient data: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text("Failed to update patient data. Please try again.")),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Patient",
          style: TextStyle(
            color: Color.fromARGB(255, 41, 41, 41), // primaryColorLight
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).primaryColorLight,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Patient Name',
                  labelStyle: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                    fontWeight: FontWeight.bold,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).primaryColorLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: ageController,
                decoration: InputDecoration(
                  labelText: 'Age',
                  labelStyle: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                    fontWeight: FontWeight.bold,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: Theme.of(context).primaryColorLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: doctorController,
                decoration: InputDecoration(
                  labelText: 'Doctor Consulted',
                  labelStyle: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                    fontWeight: FontWeight.bold,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).primaryColorLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: 'Date',
                  labelStyle: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                    fontWeight: FontWeight.bold,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
                keyboardType: TextInputType.datetime,
                style: TextStyle(
                  color: Theme.of(context).primaryColorLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Medicines:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Column(
                children: [
                  for (int i = 0; i < medicineControllers.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TextFormField(
                        controller: medicineControllers[i],
                        decoration: InputDecoration(
                          labelText: 'Medicine ${i + 1}',
                          labelStyle: TextStyle(
                            color: Theme.of(context).primaryColorLight,
                            fontWeight: FontWeight.bold,
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                        style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (medicineControllers.length < 5)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: addMedicineField,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: isLoading ? null : submitPatientData,
                child: isLoading
                    ? CircularProgressIndicator(
                        color: Theme.of(context).primaryColorLight)
                    : Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
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
