import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        // Welcome message
        const Text(
        'Hey there,\nWelcome Back!!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: Colors.black, // Use your preferred text color
        ),
      ),
      const SizedBox(height: 40.0), // Add some spacing between the text and the button
      ElevatedButton(onPressed:
            () {
          signInWithGoogle(context);
        },
            child: const Text('Login With Google')),
      ]
        ),
    )
    );
  }


  signInWithGoogle(BuildContext context) async {
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithCredential(credential);
    User? user = userCredential.user;

    // Check if the user is not null
    if (user != null) {
      // Get a reference to the Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Check if the user already exists in the 'users' collection
      //DocumentSnapshot userDoc = await firestore.collection('users').doc(user.uid).get();
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')

            .doc(user.uid)
            .get();
        // Handle document if it exists
        if (!userDoc.exists) {
          // If the user does not exist in the Firestore, create a new document
          await firestore.collection('users').doc(user.uid).set({
            'displayName': user.displayName,
            'email': user.email,
            'photoURL': user.photoURL,
            'birthdate': null, // You can update birthdate later if needed
          });
        }
      } catch (e) {
        print('Error fetching user document: $e');
        // Display error message to the user
      }



      // Navigate to the home screen after successful login
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}