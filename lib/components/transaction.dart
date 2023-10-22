import 'package:flutter/material.dart';

class TransactionPage extends StatefulWidget {
  double total;
  String paymenttype;
  TransactionPage({super.key, required this.total, required this.paymenttype});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final TextEditingController _amountTenderController = TextEditingController();

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
                    controller: _amountTenderController,
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
            onPressed: () {},
            child: const Text(
              'CHARGE',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36),
            )),
      ),
    );
  }
}
