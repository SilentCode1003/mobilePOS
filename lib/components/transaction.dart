import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:urbanhideoutpos/api/salesdetail.dart';
import 'package:urbanhideoutpos/components/cart.dart';

class TransactionPage extends StatefulWidget {
  double total;
  String paymenttype;
  Map<String, dynamic> cart;
  List<Product> products;
  TransactionPage(
      {super.key,
      required this.total,
      required this.paymenttype,
      required this.cart,
      required this.products});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final TextEditingController _amountTenderController = TextEditingController();
  final TextEditingController _paymentReferenceController =
      TextEditingController();
  List<Map<String, dynamic>> itemlist = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<void> _charge() async {
    double detailid = 1000000;
    double amount = double.parse(_amountTenderController.text);
    double change = amount - widget.total;

    for (int index = 0; index < widget.cart.length; index++) {
      String product = widget.cart.keys.elementAt(index);
      int? quantity = widget.cart[product];
      Product? productData = widget.products.firstWhere(
        (p) => p.name == product,
        orElse: () => Product("Product Not Found", 0.0, ""),
      );

      itemlist.add(
          {'name': product, 'price': productData.price, 'quantity': quantity});
    }

    print(widget.cart);
    final results = await SalesDetailAPI().sendtransaction(
        detailid.toString(),
        '1000',
        'dev42',
        widget.paymenttype,
        jsonEncode(itemlist),
        widget.total.toString());

    print(results);
    // final jsonData = json.encode(results['data']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.paymenttype} - \₱${widget.total}'),
      ),
      body: Center(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.paymenttype != 'CASH')
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 200.0,
                    maxWidth: 380.0,
                  ),
                  child: TextField(
                    controller: _paymentReferenceController,
                    keyboardType: TextInputType.number,
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
              if (widget.paymenttype != 'CASH')
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
        height: 80,
        child: ElevatedButton(
            onPressed: () {
              _charge();
            },
            child: const Text(
              'CHARGE',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36),
            )),
      ),
    );
  }
}
