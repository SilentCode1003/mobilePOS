import 'package:flutter/material.dart';
import 'package:urbanhideoutpos/components/cart.dart';
import 'package:urbanhideoutpos/components/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.brown)),

      initialRoute: '/login', // Set the initial route
      routes: {
        '/login': (context) =>
            LoginScreen(), // Define the route for MyDashboard
        '/cart': (context) => const CartPage(),
      },
    );
  }
}
