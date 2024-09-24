import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/mood_tarcker_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

 /* FirebaseAnalytics analytics = FirebaseAnalytics.instance;
   await analytics.logEvent(
       name: 'test_event',
       parameters: {'status': 'Firebase setup successful'},

   );*/
  print('Hasi le thodu');

  runApp(MeriDiaryApp());
}

class MeriDiaryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MeriDiary',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login', // Set the initial route to the Login screen
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(),
        '/goals': (context) => GoalsScreen(),
        '/expenses': (context) => ExpensesScreen(),
        '/moodTracker': (context) => MoodTrackerScreen(),
      },
    );
  }
}
