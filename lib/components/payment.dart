import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smallprojectpos/api/payment.dart';
import 'package:smallprojectpos/components/cart.dart';
import 'package:smallprojectpos/components/login.dart';
import 'package:smallprojectpos/components/transaction.dart';

class PaymentPage extends StatefulWidget {
  double total;
  Map<String, dynamic> cart;
  List<Product> products;
  int detailid;
  Function() incrementid;
  User user;

  PaymentPage(
      {super.key,
      required this.total,
      required this.cart,
      required this.products,
      required this.detailid,
      required this.incrementid,
      required this.user});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  List<String> paymentlist = [];

  @override
  void initState() {
    // TODO: implement initState
    _getpayment();
    super.initState();
  }

  Future<void> _getpayment() async {
    final results = await PaymentAPI().getPayment();
    final jsonData = json.encode(results['data']);

    print(jsonData);

    setState(() {
      for (var data in json.decode(jsonData)) {
        paymentlist.add(data['name']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> payment = List<Widget>.generate(
        paymentlist.length,
        (index) => ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionPage(
                    total: widget.total,
                    paymenttype: paymentlist[index],
                    cart: widget.cart,
                    products: widget.products,
                    detailid: widget.detailid,
                    incrementid: widget.incrementid,
                    user: widget.user,
                  ),
                ),
              );
            },
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all<Size>(Size(150, 50)),
              maximumSize: MaterialStateProperty.all<Size>(Size(200, 50)),
            ),
            child: Text(
              paymentlist[index],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )));

    return Scaffold(
      appBar: AppBar(
        title: Text('OR: ${widget.detailid} - Payment'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            Text(
              'Total: \₱${widget.total.toString()}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 36),
            ),
            const SizedBox(
              height: 40,
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: payment,
            ),
          ],
        ),
      ),
    );
  }
}
