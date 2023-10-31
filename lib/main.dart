import 'package:flutter/material.dart';
import 'package:smallprojectpos/components/cart.dart';
import 'package:smallprojectpos/components/login.dart';
import 'package:smallprojectpos/components/settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //initialize
    final User user = User("", 0);


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.brown)),

      initialRoute: '/login', // Set the initial route
      routes: {
        '/login': (context) =>
            LoginScreen(), // Define the route for MyDashboard
        '/cart': (context) => CartPage(
              user: user,
            ),
        '/setting': (context) => const SettingsPage(),
      },
    );
  }
}
