// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:globe_trans_app/config/themes.dart';
import 'package:globe_trans_app/features/contact_overview_feature/presentation/contact_overview.dart';
import 'package:globe_trans_app/features/login_screen/presentation/login_home_screen.dart';
import 'package:globe_trans_app/features/shared/auth_repository.dart';
import 'package:globe_trans_app/features/shared/database_repository.dart';
import 'package:globe_trans_app/features/shared/firebase_auth_repository.dart';
import 'package:globe_trans_app/features/shared/firebase_database_repository.dart';
import 'package:globe_trans_app/firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MultiProvider(providers: [
    Provider<DatabaseRepository>(
      create: (_) => FirebaseDatabaseRepository(),
    ),
    Provider<AuthRepository>(
      create: (_) => FirebaseAuthRepository(),
    ),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({
    super.key,
  });

  final authInstance = FirebaseAuth.instance;
  final firestoreInstance = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: myTheme,
        debugShowCheckedModeBanner: false,
        title: 'GlobeTransMessage',
        home: Scaffold(
            body: StreamBuilder<User?>(
                stream: authInstance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    User? user = snapshot.data;
                    print("User Logged In: ${user != null}");
                    if (user == null) {
                      return const LoginScreen(); // Login Screen
                    } else {
                      return const ContactView(
                        startPage: 1,
                      ); // Angemeldete User starten direkt in ChatOverView Screen
                    }
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                })));
  }
}






        
      
      // initialRoute: "/",
      // routes: {
      //   "/": (context) => const SplashScreen(),
      //   "/home": (context) => const HomeScreen()
      // },
    
  

