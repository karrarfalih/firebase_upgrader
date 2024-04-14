import 'package:firebase_upgrader/firebase_upgrader.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: FirebaseUpgrader.navigationKey,
      builder: FirebaseUpgrader.builder,
      title: 'Upgrader Example',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrader Example'),
      ),
      body: const Center(
        child: Text('Home Screen'),
      ),
    );
  }
}
