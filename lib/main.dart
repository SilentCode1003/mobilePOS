import 'package:flutter/material.dart';
import 'package:smallprojectpos/test.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: '/', // Set the initial route
      routes: {
        '/': (context) => ShoppingApp(), // Define the route for MyDashboard
      },
    );
  }
}
