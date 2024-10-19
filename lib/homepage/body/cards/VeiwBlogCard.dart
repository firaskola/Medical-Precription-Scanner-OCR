import 'package:flutter/material.dart';

class VeiwBlogCard extends StatelessWidget {
  const VeiwBlogCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        top: 16.0,
        right: 16.0,
        bottom: 0.0,
      ), // Standard margin around the container
      child: AspectRatio(
        aspectRatio: 16 / 9, // Set the aspect ratio to 16:9
        child: Container(
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/3.jpg'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(20.0), // Rounded corners
          ),
          child: Stack(
            children: [
              Positioned(
                left: 24.0,
                bottom: 24.0,
                child: Text(
                  'Healthcare Blogs',
                  style: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              Positioned(
                right: 16.0, // Right margin
                bottom: 16.0, // Bottom margin
                child: SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.35, // Set button width to 35% of screen width
                  child: TextButton(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      backgroundColor: WidgetStateProperty.all<Color>(
                        Theme.of(context).primaryColor,
                      ),
                      foregroundColor:
                          WidgetStateProperty.all<Color>(Colors.black),
                    ),
                    onPressed: () {
                      // Add your onPressed action here
                    },
                    child: Text(
                      'View Blog',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).primaryColorLight,
                      ),
                    ),
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
