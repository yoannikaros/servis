import 'package:flutter/material.dart';
import 'package:servis/screens/login_screen.dart';
import 'package:servis/helpers/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi database
  await DatabaseHelper.instance.database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Manajemen Servis',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
