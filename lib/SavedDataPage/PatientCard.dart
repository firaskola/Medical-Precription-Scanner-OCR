import 'package:flutter/material.dart';

class PatientCard extends StatelessWidget {
  final String patientName;
  final String date;
  final int age;
  final String doctorConsulted;
  final VoidCallback onTap;

  const PatientCard({
    super.key,
    required this.patientName,
    required this.date,
    required this.age,
    required this.doctorConsulted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 5,
      child: Card(
        color: const Color.fromARGB(255, 255, 235, 199),
        elevation: 3,
        margin: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(8.0), // Matches Card's borderRadius
          splashColor:
              const Color(0xFFD9D9D9).withAlpha(30), // Custom splash color
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Patient Name: $patientName',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Age: $age',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Date: $date',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Doctor: $doctorConsulted',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
