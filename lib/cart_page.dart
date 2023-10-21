import 'package:flutter/material.dart';
import 'package:smallprojectpos/test.dart';

class CartItemPage extends StatefulWidget {
  final Map<String, int> cart;
  final Function(String) removeFromCart;
  final Function(String) addToCart;
  final List<Product> products;

  CartItemPage({
    required this.cart,
    required this.removeFromCart,
    required this.addToCart,
    required this.products,
  });

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
            subtitle: Text('Total Price: \$${totalPrice.toStringAsFixed(2)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
           
                  },
                  child: const Text("DELETE ENTRY"),
                ),

                const SizedBox(
                    width: 10), // Add some spacing between the buttons
                ElevatedButton(
                  onPressed: () {
                    widget.addToCart(product);
                    setState(() {});
                  },
                  child: const Text("+"),
                ),

                ElevatedButton(
                  onPressed: () {
                    widget.removeFromCart(product);
                    setState(() {});
                  },
                  child: const Text("-"),
                ),
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
              subtitle: const Text('Total Price: \$0.00'),
              trailing: ElevatedButton(
                onPressed: () {
                  widget.removeFromCart(product);
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
        title: const Text('My Cart'),
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
            subtitle: Text('Total Price: \$${total.toStringAsFixed(2)}'),
            trailing: ElevatedButton(
              onPressed: () {
                // Add your action when the "Confirm Payment" button is pressed here.
              },
              child: const Text('Confirm Payment'),
            ),
          ),
        ],
      ),
    );
  }
}
