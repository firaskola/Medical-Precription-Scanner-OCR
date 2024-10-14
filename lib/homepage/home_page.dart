import 'package:flutter/material.dart';
import 'package:medicare/homepage/appbar/appbar.dart';
import 'package:medicare/homepage/appbar/navdrawer.dart';
import 'package:medicare/homepage/body/body.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      drawer: Navdrawer(),
      appBar: CustomAppBar(),
      body: MainBody(),
    );
  }
}
