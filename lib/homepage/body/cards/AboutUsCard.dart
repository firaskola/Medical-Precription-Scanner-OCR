import 'package:flutter/material.dart';

class AboutUsCard extends StatelessWidget {
  const AboutUsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: 16.0,
          left: 16.0,
          right: 16.0,
          bottom: 0.0), // Standard margin around the container
      child: AspectRatio(
        aspectRatio: 16 / 9, // Set the aspect ratio to 16:9
        child: Container(
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/2.jpg'),
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
                      'Know More About Us',
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
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        backgroundColor: WidgetStateProperty.all<Color>(
                            Theme.of(context).primaryColor),
                        foregroundColor:
                            WidgetStateProperty.all<Color>(Colors.black),
                      ),
                      onPressed: () {
                        // Add your onPressed action here
                      },
                      child: Text(
                        'About Us',
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
