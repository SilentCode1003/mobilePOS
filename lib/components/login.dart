import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:uhpos/api/login.dart';
import 'package:uhpos/components/cart.dart';
import 'package:uhpos/components/loadingspinner.dart';
import 'package:uhpos/components/settings.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  User user = User("", "");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<void> login() async {
    final BuildContext capturedContext = context;
    try {
      String username = _usernameController.text;
      String password = _passwordController.text;
      final results = await LoginAPI().getLogin(username, password);
      final jsonData = json.encode(results['data']);

      if (username == "" && password == "") {
        return showDialog(
            context: capturedContext,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Empty Fields'),
                content: const Text('Username and Password is empty'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(capturedContext),
                      child: const Text('OK'))
                ],
              );
            });
      }

      if (results['msg'] == 'success') {
        if (jsonData.length == 2) {
          showDialog(
              context: capturedContext,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Warning'),
                  content: const Text('Username and Password not match!'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'))
                  ],
                );
              });
        } else {
          setState(() {
            for (var data in json.decode(jsonData)) {
              print('${data['fullname']} ${data['accesstype']}');
              user = User(data['fullname'], data['accesstype']);
            }
          });

          showDialog(
              context: capturedContext,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Login Success'),
                  content: const Text('Login Successfull'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CartPage(
                                  user: user,
                                ),
                              ),
                            ),
                        child: const Text('OK'))
                  ],
                );
              });
        }
      } else {
        showDialog(
            context: capturedContext,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text('${results['msg']}'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'))
                ],
              );
            });
      }
    } catch (e) {
      showDialog(
          context: capturedContext,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('$e'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'))
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                height: 200,
                width: 200,
                child: ClipOval(
                    child: Image.asset(
                  'assets/logo.jpg',
                  fit: BoxFit.fill,
                ))),
            const SizedBox(height: 40),
            const Text(
              'Urban Hideout POS',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              constraints: const BoxConstraints(
                minWidth: 200.0,
                maxWidth: 280.0,
              ),
              child: TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  border: OutlineInputBorder(),
                  hintText: 'Enter Username',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              constraints: const BoxConstraints(
                minWidth: 200.0,
                maxWidth: 280.0,
              ),
              child: TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  border: OutlineInputBorder(),
                  hintText: 'Enter Password',
                  prefixIcon: Icon(Icons.password),
                ),
                obscureText: true,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              constraints: const BoxConstraints(
                minWidth: 200.0,
                maxWidth: 280.0,
              ),
              child: ElevatedButton(
                onPressed: () {
                  // Navigator.pushReplacementNamed(context, '/cart');
                  login();
                },
                style: ElevatedButton.styleFrom(
                    side: const BorderSide(width: 2),
                    textStyle: const TextStyle(
                        fontSize: 32, fontStyle: FontStyle.normal)),
                child: const Text(
                  'LOGIN',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//User Class
class User {
  final String fullname;
  final String access;

  User(this.fullname, this.access);

  User.fromMap(Map<String, dynamic> map)
      : fullname = map['fullname'],
        access = map['access'];
}
