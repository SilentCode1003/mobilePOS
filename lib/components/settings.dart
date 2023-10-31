import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _storeController = TextEditingController();
  final TextEditingController _posController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              constraints: const BoxConstraints(
                minWidth: 200.0,
                maxWidth: 380.0,
              ),
              child: TextField(
                controller: _storeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  labelText: 'Store ID',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  border: OutlineInputBorder(),
                  hintText: 'Enter Store ID',
                  prefixIcon: Icon(Icons.store),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              constraints: const BoxConstraints(
                minWidth: 200.0,
                maxWidth: 380.0,
              ),
              child: TextField(
                controller: _posController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  labelText: 'POS ID',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  border: OutlineInputBorder(),
                  hintText: 'Enter POS ID',
                  prefixIcon: Icon(Icons.desktop_windows),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
                constraints: const BoxConstraints(
                  minWidth: 200.0,
                  maxWidth: 380.0,
                ),
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.sync),
                  label: const Text('SYNC'),
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all<Size>(Size(double.maxFinite, 50)),
                    maximumSize: MaterialStateProperty.all<Size>(Size(double.maxFinite, 50)),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
