import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  String? profileImageUrl;
  String? bannerImageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchProfileAndBannerImages();
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

  Future<void> fetchProfileAndBannerImages() async {
    try {
      // Fetch profile image
      String profilePath = 'users/${user!.uid}/profile.jpg';
      try {
        profileImageUrl =
            await FirebaseStorage.instance.ref(profilePath).getDownloadURL();
      } catch (e) {
        print('Profile image not found: $e');
        profileImageUrl = null; // Set to null if not found
      }

      // Fetch banner image
      String bannerPath = 'users/${user!.uid}/banner.jpg';
      try {
        bannerImageUrl =
            await FirebaseStorage.instance.ref(bannerPath).getDownloadURL();
      } catch (e) {
        print('Banner image not found: $e');
        bannerImageUrl = null; // Set to null if not found
      }

      setState(() {}); // Ensure UI updates after fetching images
    } catch (e) {
      print('Error fetching images: $e');
    }
  }

  Future<void> uploadImage(String type, XFile image) async {
    try {
      String imagePath = 'users/${user!.uid}/$type.jpg';
      await FirebaseStorage.instance.ref(imagePath).putFile(File(image.path));

      // Fetch the updated profile and banner images
      await fetchProfileAndBannerImages(); // Refresh the images

      // Optionally, you can set the profileImageUrl or bannerImageUrl directly here
      // if you want to avoid fetching again
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> removeImage(String type) async {
    try {
      String imagePath = 'users/${user!.uid}/$type.jpg';
      await FirebaseStorage.instance.ref(imagePath).delete();
      await fetchProfileAndBannerImages(); // Refresh the images after deletion
    } catch (e) {
      print('Error removing image: $e');
    }
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
              Divider(
                color: Theme.of(context).primaryColor,
                thickness: 1.0,
                indent: 8.0,
                endIndent: 8.0,
              ),
              ListTile(
                leading: Icon(CupertinoIcons.delete,
                    color: Theme.of(context).primaryColor),
                title: const Text('Remove Banner Image'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                onTap: () {
                  Navigator.pop(context);
                  removeImage('banner');
                },
              ),
              Divider(
                color: Theme.of(context).primaryColor,
                thickness: 1.0,
                indent: 8.0,
                endIndent: 8.0,
              ),
              ListTile(
                leading: Icon(CupertinoIcons.delete,
                    color: Theme.of(context).primaryColor),
                title: const Text('Remove Profile Image'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                onTap: () {
                  Navigator.pop(context);
                  removeImage('profile');
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
        await uploadImage(type, image);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
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
                child: profileImageUrl != null
                    ? Image.network(profileImageUrl!,
                        width: 90, height: 90, fit: BoxFit.cover)
                    : Image.asset(
                        'assets/profile.jpg',
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 235, 193, 102),
              image: DecorationImage(
                image: bannerImageUrl != null
                    ? NetworkImage(bannerImageUrl!)
                    : const AssetImage('assets/banner.jpg') as ImageProvider,
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
              style: TextStyle(color: Color.fromARGB(255, 255, 0, 0)),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
