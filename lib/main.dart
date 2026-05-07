import 'package:flutter/material.dart';
import 'package:trainer_listing/pages/auth/login_page.dart';
import 'package:trainer_listing/pages/auth/register_page.dart';
import 'package:trainer_listing/pages/clients/clients_list_page.dart';
import 'package:trainer_listing/pages/home/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitEd Trainer',
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/clients': (context) => const ClientsListPage(),
      },
    );
  }
}
