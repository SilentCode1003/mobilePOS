import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:uhpos/api/pos.dart';
import 'package:uhpos/api/store.dart';
import 'package:uhpos/components/login.dart';
import 'package:uhpos/repository/database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SyncingPage extends StatefulWidget {
  const SyncingPage({super.key});

  @override
  State<SyncingPage> createState() => _SyncingPageState();
}

class _SyncingPageState extends State<SyncingPage> {
  final TextEditingController _storeController = TextEditingController();
  final TextEditingController _posController = TextEditingController();
  final DatabaseHelper dh = DatabaseHelper();
  bool issync = false;
  double statuspercentage = 0;

  String storelogo = '';

  @override
  void initState() {
    // TODO: implement initState
    _checkdatabase();
    super.initState();
  }

  Future<void> _checkdatabase() async {
    final BuildContext capturedContext = context;
    try {
      final Database db = await dh.database;

      List<Map<String, dynamic>> posconfig = await db.query('pos');
      List<Map<String, dynamic>> storeconfig = await db.query('store');

      if (posconfig.isNotEmpty && storeconfig.isNotEmpty) {
        setState(() {
          issync = true;
        });
      } else {
        if (posconfig.isNotEmpty) {
          for (var pos in posconfig) {
            // String LoadSpinner = pos['posid'];
            print('${pos['posid']}');
            setState(() {
              _posController.text = pos['posid'].toString();
            });
            // Process data
          }
        }

        if (storeconfig.isNotEmpty) {
          for (var branch in storeconfig) {
            // String name = pos['posid'];
            print('${branch['storeid']}');

            setState(() {
              storelogo = branch['logo'];
              _storeController.text = branch['storeid'];
            });
            // Process data
          }
        }

        showDialog(
            context: capturedContext,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Config'),
                content: const Text('Setup POS ID & Store ID'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(capturedContext),
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
              content: Text('$e}'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'))
              ],
            );
          });
    }
  }

  Future<void> _sync() async {
    final BuildContext capturedContext = context;
    String storeid = _storeController.text;
    String posid = _posController.text;

    if (storeid == '' || posid == '') {
      showDialog(
          context: capturedContext,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Empty Fields'),
              content: const Text('Store ID & POS ID is required to fillup'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'))
              ],
            );
          });
    } else {
      showDialog(
          context: capturedContext,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return LoadSpinner(
              storeid: storeid,
              posid: posid,
            );
          });
    }
  }

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
                  onPressed: () {
                    _sync();
                  },
                  icon: const Icon(Icons.sync),
                  label: const Text('SYNC'),
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all<Size>(
                        Size(double.maxFinite, 50)),
                    maximumSize: MaterialStateProperty.all<Size>(
                        Size(double.maxFinite, 50)),
                  ),
                )),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        child: ElevatedButton(
            onPressed: () {
              _checkdatabase();
            },
            child: const Text(
              'Back',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
            )),
      ),
    );
  }
}

class LoadSpinner extends StatefulWidget {
  String storeid;
  String posid;

  LoadSpinner({super.key, required this.storeid, required this.posid});

  @override
  State<LoadSpinner> createState() => _LoadSpinnerState();
}

class _LoadSpinnerState extends State<LoadSpinner> {
  final DatabaseHelper dh = DatabaseHelper();
  bool issync = false;

  String title = '';

  @override
  void initState() {
    // TODO: implement initState
    _getpos(widget.posid);
    _getstore(widget.storeid);

    super.initState();
  }

  Future<String> _getpos(posid) async {
    title = 'POS Config';
    Database db = await dh.database;
    // String posid = _posController.text;
    final results = await PosAPI().getPOS(posid);
    final jsonData = json.encode(results['data']);
    List<Map<String, dynamic>> posconfig = await db.query('pos');

    if (posconfig.isNotEmpty) {
      for (var pos in posconfig) {
        // String name = pos['posid'];
        print('${pos['posid']}');
        dh.updateItem(pos, 'pos', 'posid=?', pos['posid']);
        // Process data
      }
      return 'success';
    } else {
      if (jsonData.length != 2) {
        for (var data in json.decode(jsonData)) {
          await dh.insertItem({
            "posid": data['id'],
            "posname": data['name'],
            "serial": data['serial'],
            "min": data['min'],
            "ptu": data['ptu'],
          }, 'pos');
        }

        List<Map<String, dynamic>> posconfig = await db.query('branch');
        for (var pos in posconfig) {
          print(
              '${pos['posid']} ${pos['posname']} ${pos['serial']} ${pos['min']} ${pos['ptu']}');
        }

        setState(() {
          issync = true;
        });

        return 'success';
      } else {
        return 'error';
      }
    }
  }

  Future<String> _getstore(storeid) async {
    title = 'Store Config';
    Database db = await dh.database;
    // String posid = _posController.text;
    final results = await StoreAPI().getStore(storeid);
    final jsonData = json.encode(results['data']);
    List<Map<String, dynamic>> storeconfig = await db.query('store');

    if (storeconfig.isNotEmpty) {
      for (var store in storeconfig) {
        // String name = pos['posid'];
        print('${store['posid']}');
        dh.updateItem(store, 'store', 'storeid=?', store['storeid']);
        // Process data
      }
      return 'success';
    } else {
      if (jsonData.length != 2) {
        for (var data in json.decode(jsonData)) {
          await dh.insertItem({
            "storeid": data['id'],
            "storename": data['name'],
            "logo": data['logo'],
            "address": data['address'],
            "contact": data['contact'],
            "message": data['message'],
          }, 'store');
        }

        List<Map<String, dynamic>> storeconfig = await db.query('store');
        for (var store in storeconfig) {
          print(
              '${store['storeid']} ${store['storename']} ${store['logo']} ${store['address']} ${store['contact']} ${store['message']}');
        }

        setState(() {
          issync = true;
        });

        return 'success';
      } else {
        return 'error';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CircularPercentIndicator(
            animation: true,
            animationDuration: 1000,
            radius: 200,
            lineWidth: 20,
            percent: 1,
            progressColor: Colors.brown,
            backgroundColor: Colors.brown.shade100,
            center: Text(
              '$title 100%',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
              style: const ButtonStyle(
                  minimumSize: MaterialStatePropertyAll(Size(200, 80))),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Done'))
        ],
      ),
    ));
  }
}
