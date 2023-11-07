import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uhpos/api/customercredit.dart';
import 'package:uhpos/api/salesdetail.dart';
import 'package:uhpos/components/cart.dart';
import 'package:uhpos/components/login.dart';
import 'package:uhpos/repository/database.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:uhpos/repository/helper.dart';

class TransactionPage extends StatefulWidget {
  double total;
  String paymenttype;
  Map<String, dynamic> cart;
  List<Product> products;
  int detailid;
  Function() incrementid;
  User user;

  TransactionPage(
      {super.key,
      required this.total,
      required this.paymenttype,
      required this.cart,
      required this.products,
      required this.detailid,
      required this.incrementid,
      required this.user});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final TextEditingController _amountTenderController = TextEditingController();
  final TextEditingController _paymentReferenceController =
      TextEditingController();
  final TextEditingController _customerIDController = TextEditingController();
  List<Map<String, dynamic>> itemlist = [];
  List<Map<String, dynamic>> detaillist = [];

  DatabaseHelper dh = DatabaseHelper();
  String posname = '';
  int posid = 0;

  double cash = 0;
  double uhpoints = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<void> _charge(double cash) async {
    try {
      showDialog(
          context: context,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });

      String paymenttype = widget.paymenttype;
      String customerid = _customerIDController.text;
      String amounttender = _amountTenderController.text;
      String referenceno = _paymentReferenceController.text;
      String message = '';

      if (paymenttype != "CASH") {
        if (paymenttype == "UH POINTS") {
          if (customerid == '') {
            message += 'Customer ID ';
          }
          if (amounttender == '') {
            message += 'Cash ';
          }
        } else {
          if (referenceno == '') {
            message += 'Reference No. ';
          }

          if (amounttender == '') {
            message += 'Cash ';
          }
        }
      } else {
        if (amounttender == '') {
          message += 'Cash ';
        }
      }

      if (message != '') {
          Navigator.of(context).pop();
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Empty'),
                content:
                    Text('Do not leave blank inputs especially [$message]'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'OK',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              );
            });
      } else {
        if (paymenttype == 'UH POINTS') {
          final results = await CustomerCreditAPI().getcredit(customerid);
          final jsonData = json.encode(results['data']);

          if (results['msg'] == 'success') {
            if (jsonData.length == 2) {
               Navigator.of(context).pop();
              return showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Not Found'),
                      content: Text('Customer ID $customerid is not found!'),
                      actions: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'))
                      ],
                    );
                  });
            } else {
              for (var data in json.decode(jsonData)) {
                int balance = data['balance'];
                double credit = balance.toDouble();

                if (credit < cash) {
                   Navigator.of(context).pop();
                  return showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Insufficient'),
                          content: Text(
                              'Insufficient balance, your current balance is $credit'),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'))
                          ],
                        );
                      });
                }
              }
            }
          }
        }

        Database db = await dh.database;
        List<Map<String, dynamic>> posconfig = await db.query('pos');

        for (var pos in posconfig) {
          // print(
          //     '${pos['posid']} ${pos['posname']} ${pos['serial']} ${pos['min']} ${pos['ptu']}');
          posname = pos['posname'];
          posid = pos['posid'];
          setState(() {});
        }

        // double cashtender = double.tryParse(_amountTenderController.text) ?? 0;
        double change = cash - widget.total;

        for (int index = 0; index < widget.cart.length; index++) {
          String product = widget.cart.keys.elementAt(index);
          int? quantity = widget.cart[product];
          Product? productData = widget.products.firstWhere(
            (p) => p.name == product,
            orElse: () => Product("Product Not Found", 0.0, ""),
          );

          itemlist.add({
            'name': product,
            'price': productData.price,
            'quantity': quantity,
          });
        }

        detaillist.add({
          'items': itemlist,
          if (paymenttype == 'CASH') 'cash': cash,
          if (paymenttype != 'CASH' && paymenttype != 'UH POINTS')
            'ecash': cash,
          if (paymenttype != 'CASH' && paymenttype != 'UH POINTS')
            'reference': referenceno,
          if (paymenttype == "UH POINTS") 'customerid': customerid,
          if (paymenttype == "UH POINTS") 'points': cash,
        });

        print(detaillist);

        if (cash < widget.total) {
          Navigator.of(context).pop();
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Insufficient Funds'),
                  content: Text(
                      '${widget.total} is the total bill, but you tender only $cash'),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'OK',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                );
              });
        } else {
          final results = await SalesDetailAPI().sendtransaction(
              widget.detailid.toString(),
              posid.toString(),
              widget.user.fullname,
              widget.paymenttype,
              jsonEncode(itemlist),
              widget.total.toString());

          Navigator.of(context).pop();

          if (results['msg'] != 'success') {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Failed'),
                    content: Text('${results['msg']}'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'))
                    ],
                  );
                });
          } else {
            setState(() {
              widget.incrementid;
            });

            Navigator.of(context).pop();

            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Transaction Complete'),
                    content: Text(
                        'Cash:${formatAsCurrency(cash)}\nTotal:${formatAsCurrency(widget.total)}\nChange: ${formatAsCurrency(change)}'),
                    actions: [
                      // ElevatedButton(
                      //     onPressed: () {},
                      //     child: const Text(
                      //       'Send Receipt',
                      //       style: TextStyle(
                      //           fontSize: 16, fontWeight: FontWeight.w600),
                      //     )),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CartPage(
                                user: widget.user,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'OK',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  );
                });
          }
        }
      }

      // final jsonData = json.encode(results['data']);
    } catch (e) {
      Navigator.of(context).pop();
      showDialog(
          context: context,
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
      appBar: AppBar(
        title:
            Text('${widget.paymenttype} - ${formatAsCurrency(widget.total)}'),
      ),
      body: Center(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.paymenttype != 'CASH' &&
                  widget.paymenttype != 'UH POINTS')
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 200.0,
                    maxWidth: 380.0,
                  ),
                  child: TextField(
                    controller: _paymentReferenceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'[a-zA-Z]')),
                    ],
                    decoration: const InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                      labelText: 'Reference No.',
                      labelStyle:
                          TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      border: OutlineInputBorder(),
                      hintText: 'Enter Reference No.',
                      prefixIcon: Icon(Icons.receipt_rounded),
                    ),
                  ),
                ),
              if (widget.paymenttype == 'UH POINTS')
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 200.0,
                    maxWidth: 380.0,
                  ),
                  child: TextField(
                    controller: _customerIDController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'[a-zA-Z]')),
                    ],
                    decoration: const InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                      labelText: 'Customer ID',
                      labelStyle:
                          TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      border: OutlineInputBorder(),
                      hintText: 'Enter Customer ID',
                      prefixIcon: Icon(Icons.person_3),
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
                child: TextField(
                  controller: _amountTenderController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    // FilteringTextInputFormatter.deny(RegExp(r'[a-zA-Z]')),
                    CurrencyInputFormatter()
                  ],
                  onChanged: (value) {
                    // Remove currency symbols and commas to get the numeric value
                    String numericValue = value.replaceAll(
                      RegExp('[,]'),
                      '',
                    );

                    setState(() {
                      cash = double.tryParse(numericValue) ?? 0;
                      print(cash);
                    });
                  },
                  decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    labelText: 'Cash Tender',
                    labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    border: OutlineInputBorder(),
                    hintText: 'Enter Cash Amount',
                    prefixIcon: Icon(Icons.monetization_on),
                  ),
                ),
              )
            ]),
      ),
      bottomNavigationBar: Container(
        height: 60,
        child: ElevatedButton(
            onPressed: () {
              _charge(cash);
            },
            child: const Text(
              'CHARGE',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
            )),
      ),
    );
  }
}
