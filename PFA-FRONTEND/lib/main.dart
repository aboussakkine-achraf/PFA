import 'package:flutter/material.dart';
import 'IdentityFileScreen.dart'; // Import the IdentityFileScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: IdentityFileScreen(), // Removed const here as per your request
    );
  }
}
