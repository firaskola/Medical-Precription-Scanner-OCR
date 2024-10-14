import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgetPasswordPage extends StatelessWidget {
  const ForgetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller for the email field
    final TextEditingController emailController = TextEditingController();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Forgot Password?',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32.0),
            TextFormField(
              controller: emailController, // Attach the controller here
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Enter your email',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onPressed: () async {
                // Implement password reset functionality
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: emailController.text.trim(),
                  );

                  // Show a message to the user
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password reset email sent!')),
                  );

                  // Optionally, navigate back to the Login page
                  Navigator.pop(context);
                } on FirebaseAuthException catch (e) {
                  // Handle errors
                  print('Error sending password reset email: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.message ?? 'Error occurred')),
                  );
                }
              },
              child: const Text(
                'Reset Password',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Remembered your password? ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Navigate back to the Login page
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
