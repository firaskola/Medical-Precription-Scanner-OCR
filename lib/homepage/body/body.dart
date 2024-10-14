import 'package:flutter/material.dart';
import 'package:medicare/homepage/body/cards/AboutUsCard.dart';
import 'package:medicare/homepage/body/cards/EditPrescriptionCard.dart';
import 'package:medicare/homepage/body/cards/PrescriptionCard.dart';
import 'package:medicare/homepage/body/cards/VeiwBlogCard.dart';

class MainBody extends StatefulWidget {
  const MainBody({super.key});

  @override
  _MainBodyState createState() => _MainBodyState();
}

class _MainBodyState extends State<MainBody> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PrescriptionCard(),
            EditPrescriptionCard(),
            VeiwBlogCard(),
            AboutUsCard(),
          ],
        ),
      ),
    );
  }
}
