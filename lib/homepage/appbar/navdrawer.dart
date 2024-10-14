import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class Navdrawer extends StatefulWidget {
  const Navdrawer({super.key});

  @override
  _NavdrawerState createState() => _NavdrawerState();
}

class _NavdrawerState extends State<Navdrawer> {
  final User? user = FirebaseAuth.instance.currentUser;
  String? firstName;
  String? lastName;
  final ImagePicker _picker = ImagePicker();

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
            .doc('users')
            .collection('users')
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

  // Confirmation dialog for sign-out
  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await signout();
                Navigator.of(context).pop(); // Close the dialog
                // Optionally navigate to the login page or perform other actions
              },
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  void _showImageTypeOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(CupertinoIcons.photo,
                    color: Theme.of(context).primaryColor),
                title: const Text('Upload Banner Image'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showImageSourceOptions(context, 'banner');
                },
              ),
              Divider(
                color: Theme.of(context).primaryColor,
                thickness: 1.0,
                indent: 8.0,
                endIndent: 8.0,
              ),
              ListTile(
                leading: Icon(CupertinoIcons.person_crop_circle,
                    color: Theme.of(context).primaryColor),
                title: const Text('Upload Profile Image'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showImageSourceOptions(context, 'profile');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImageSourceOptions(BuildContext context, String type) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(CupertinoIcons.photo_on_rectangle,
                    color: Theme.of(context).primaryColor),
                title: const Text('Upload Image'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, type);
                },
              ),
              Divider(
                color: Theme.of(context).primaryColor,
                thickness: 1.0,
                indent: 8.0,
                endIndent: 8.0,
              ),
              ListTile(
                leading: Icon(CupertinoIcons.camera,
                    color: Theme.of(context).primaryColor),
                title: const Text('Take a Picture'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, type);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source, String type) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        print('Image selected: ${image.path}');
        // Handle the image file based on the 'type' (banner or profile)
        // You can upload it to Firebase or use it locally in your app
      }
    } catch (e) {
      print('Error picking image: $e');
    }
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
            leading: const Icon(
              CupertinoIcons.cloud_upload,
            ),
            title: const Text('Upload shot'),
            onTap: () {
              _showImageTypeOptions(context);
            },
          ),
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
            onTap: _confirmSignOut, // Call the confirmation method
          ),
          const Divider(),
        ],
      ),
    );
  }
}
