import 'package:flutter/material.dart';
import 'user_interface/base_screen.dart'; // Import the BaseScreen

void main() {
  runApp(ProofItApp());
}

class ProofItApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProofIt',
      theme: ThemeData(
        primaryColor: Colors.green[700],
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.greenAccent),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BaseScreen(), // Use the BaseScreen from the imported file
    );
  }
}