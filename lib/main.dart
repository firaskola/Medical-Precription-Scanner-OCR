import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medicare/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
    ],
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //final textTheme = Theme.of(context).textTheme; // Define textTheme

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Wrapper(),
      theme: ThemeData(
        //textTheme: GoogleFonts.robotoTextTheme(textTheme).copyWith(
        // bodyMedium: GoogleFonts.roboto(textStyle: textTheme.labelSmall),
        // ),
        primaryColorLight: const Color.fromARGB(255, 41, 41, 41),
        // indicatorColor: const Color.fromARGB(75, 81, 81, 183),
        primaryColor: const Color.fromRGBO(249, 189, 78, 1),
      ), // Close theme parameter here
    );
  }
}
