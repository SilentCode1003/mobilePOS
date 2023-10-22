import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                height: 120,
                width: 120,
                child: ClipOval(
                    child: Image.asset(
                  'assets/logo.jpg',
                  fit: BoxFit.fill,
                ))),
            const SizedBox(height: 40),
            const Text(
              'Urban Hideout POS',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              constraints: const BoxConstraints(
                minWidth: 200.0,
                maxWidth: 280.0,
              ),
              child: const TextField(
                decoration: InputDecoration(labelText: 'Username'),
              ),
            ),
            Container(
              constraints: const BoxConstraints(
                minWidth: 200.0,
                maxWidth: 280.0,
              ),
              child: const TextField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/cart');
              },
              style: ElevatedButton.styleFrom(
                  side: const BorderSide(width: 2),
                  textStyle: const TextStyle(
                      fontSize: 48, fontStyle: FontStyle.normal)),
              child: const Text(
                'LOGIN',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
