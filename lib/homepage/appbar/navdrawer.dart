import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Navdrawer extends StatefulWidget {
  const Navdrawer({super.key});

  @override
  _NavdrawerState createState() => _NavdrawerState();
}

class _NavdrawerState extends State<Navdrawer> {
  final User? user = FirebaseAuth.instance.currentUser;
  String? firstName;
  String? lastName;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final userEmail = user?.email;
    if (userEmail != null) {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Medicare')
            .doc('users') // Assuming 'users' is a document under 'Medicare'
            .collection(
                'users') // Assuming 'users' is also a sub-collection if this is not correct adjust accordingly
            .where('email', isEqualTo: userEmail)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          var doc = querySnapshot.docs.first;
          setState(() {
            firstName = doc['first_name'] ?? 'No First Name';
            lastName = doc['last_name'] ?? 'No Last Name';
          });
        } else {
          print('No user found with the given email.');
        }
      } catch (error) {
        print('Error fetching user data: $error');
      }
    }
  }

  Future<void> signout() async {
    await FirebaseAuth.instance.signOut();
    // Navigate back to login or any other page after sign-out if needed
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              firstName != null && lastName != null
                  ? '$firstName $lastName'
                  : 'Loading...',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              user?.email ?? 'Email not available',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.asset(
                  'assets/prescription.jpg',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 235, 193, 102),
              image: DecorationImage(
                image: const AssetImage('assets/med.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.cloud_upload),
            title: const Text('Upload shot'),
            onTap: () {
              // Implement navigation or functionality here
            },
          ),
          // Other ListTiles ...
          ListTile(
            leading: const Icon(
              CupertinoIcons.square_arrow_right,
              color: Color.fromARGB(255, 255, 0, 0),
            ),
            title: const Text(
              'Signout',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 0, 0),
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: signout,
          ),
          const Divider(),
        ],
      ),
    );
  }
}
