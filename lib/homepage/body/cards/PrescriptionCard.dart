import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';

class PrescriptionCard extends StatelessWidget {
  const PrescriptionCard({super.key});

  Future<bool> isCameraAvailable() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        // Log camera details
        cameras.forEach((camera) {
          print('Camera found: ${camera.name}');
        });
        return true;
      } else {
        print("No cameras found.");
        return false;
      }
    } catch (e) {
      print("Camera error: $e");
      return false;
    }
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    // Check if the camera is requested
    if (source == ImageSource.camera) {
      // Check if the camera is available
      final cameraAvailable = await isCameraAvailable();
      if (!cameraAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Camera is not available")),
        );
        return;
      }
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      // Process the image here (e.g., display or upload)
      print("Image path: ${image.path}");
    } else {
      print('No image selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
        left: 16.0,
        right: 16.0,
        bottom: 0.0,
      ), // Standard margin around the container
      child: AspectRatio(
        aspectRatio: 16 / 9, // Set the aspect ratio to 16:9
        child: Container(
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/4.jpg'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(20.0), // Rounded corners
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Prescription Scanner',
                      style: TextStyle(
                        color: Theme.of(context).primaryColorLight,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).primaryColor,
                        ),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.black),
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (BuildContext context) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {
                                      _pickImage(context, ImageSource.gallery);
                                      Navigator.pop(context);
                                    },
                                    child: ListTile(
                                      leading: Icon(
                                        CupertinoIcons.photo,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      title: Text(
                                        'Upload Image',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Divider(
                                      color: Theme.of(context).primaryColor),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {
                                      _pickImage(context, ImageSource.camera);
                                      Navigator.pop(context);
                                    },
                                    child: ListTile(
                                      leading: Icon(
                                        CupertinoIcons.camera,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      title: Text(
                                        'Take Image',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Text(
                        'Upload Image',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).primaryColorLight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
