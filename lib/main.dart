import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:untitled6/admindashboard.dart';
import 'auth_service.dart';
import 'dashboard.dart';
import 'login.dart';


void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'AIzaSyBqqYiKTY0cyW-1TjbACtnp3ZQBYDhKGD4',
        appId: '1:888042064588:android:fdff33239733f0f8271069',
        messagingSenderId: '888042064588',
        projectId: 'barbershop-f889c',
        storageBucket: 'myapp-b9yt18.appspot.com',
      )
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrimTime',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: _authService.getCurrentUser() != null
          ? (_authService.getCurrentUser()?.email == "brbradmin@admin.com"
          ? Admindashboard()
          : DashboardPage())
          : LoginPage(),

    );
  }
}
