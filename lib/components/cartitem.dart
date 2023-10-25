import 'package:flutter/material.dart';
import 'package:urbanhideoutpos/components/cart.dart';
import 'package:urbanhideoutpos/components/payment.dart';

class CartItemPage extends StatefulWidget {
  final Map<String, int> cart;
  final Function(String) deductToCart;
  final Function(String) addToCart;
  final Function(String) removeToCart;
  final List<Product> products;
  final int detailid;
  final Function() incrementid;

  CartItemPage(
      {required this.cart,
      required this.deductToCart,
      required this.addToCart,
      required this.products,
      required this.removeToCart,
      required this.detailid,
      required this.incrementid});

  @override
  _CartItemPageState createState() => _CartItemPageState();
}

class _CartItemPageState extends State<CartItemPage> {
  @override
  Widget build(BuildContext context) {
    double total = 0.0;

    List<Widget> cartItems = [];
    for (int index = 0; index < widget.cart.length; index++) {
      String product = widget.cart.keys.elementAt(index);
      int? quantity = widget.cart[product];
      Product? productData = widget.products.firstWhere(
        (p) => p.name == product,
        orElse: () => Product("Product Not Found", 0.0, ""),
      );

      if (productData != null) {
        double totalPrice = productData.price * quantity!;
        total += totalPrice;
        cartItems.add(Card(
          elevation: 3,
          margin: const EdgeInsets.all(5),
          child: ListTile(
            title: Text('$product (QTY $quantity)'),
            subtitle: Text('Total Price: \₱${totalPrice.toStringAsFixed(2)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    widget.addToCart(product);
                    setState(() {});
                  },
                  child: const Text("+"),
                ),
                const SizedBox(
                    width: 5), // Add some spacing between the buttons
                ElevatedButton(
                  onPressed: () {
                    widget.deductToCart(product);
                    setState(() {});
                  },
                  child: const Text("-"),
                ),
                const SizedBox(
                    width: 16), // Add some spacing between the buttons
                ElevatedButton.icon(
                    onPressed: () {
                      widget.removeToCart(product);
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    label: const Text('REMOVE')),
              ],
            ),
          ),
        ));
      } else {
        cartItems.add(
          Card(
            elevation: 3,
            margin: const EdgeInsets.all(5),
            child: ListTile(
              title: const Text('Product Not Found'),
              subtitle: const Text('Total Price: \₱0.00'),
              trailing: ElevatedButton(
                onPressed: () {
                  widget.deductToCart(product);
                  setState(() {});
                },
                child: const Text("Remove"),
              ),
            ),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('OR:${widget.detailid} - Item List'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: cartItems,
            ),
          ),
          ListTile(
            title: const Text('Total',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Total Price: \₱${total.toStringAsFixed(2)}'),
            trailing: ElevatedButton(
              onPressed: () {
                // Add your action when the "Confirm Payment" button is pressed here.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentPage(
                      total: total,
                      cart: widget.cart,
                      products: widget.products,
                      detailid: widget.detailid,
                      incrementid: widget.incrementid,
                    ),
                  ),
                );
              },
              child: const Text('Confirm Payment'),
            ),
          ),
        ],
      ),
    );
  }
}
