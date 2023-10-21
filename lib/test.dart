import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:smallprojectpos/api/product.dart';
import 'package:smallprojectpos/cart_page.dart';
import 'package:smallprojectpos/model/product.dart';

void main() {
  runApp(ShoppingApp());
}

class ShoppingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ShoppingCartPage(),
    );
  }
}

class ShoppingCartPage extends StatefulWidget {
  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  Map<String, int> cart = {};
  int totalCartItems = 0;
  Map<String, double> totalPrices = {};
  // List<ProductModel> productlist = [];

  List<Product> productlist = [];
  @override
  void initState() {
    super.initState();
    _getproductlist();
    updateTotalCartItems();
  }

  Future<void> _getproductlist() async {
    final results = await ProductAPI().getProduct();
    final jsonData = json.encode(results['data']);

    setState(() {
      for (var data in json.decode(jsonData)) {
        productlist
            .add(Product(data['description'], data['price'].toDouble(), data['image']));
      }
    });
  }

  void updateTotalCartItems() {
    int total = 0;
    cart.forEach((product, quantity) {
      total += quantity;
    });
    setState(() {
      totalCartItems = total;
    });
  }

  void addToCart(String product) {
    setState(() {
      if (cart.containsKey(product)) {
        cart[product] = (cart[product] ?? 0) + 1;
        totalPrices[product] = (totalPrices[product] ?? 0) +
            productlist.firstWhere((p) => p.name == product).price;
      } else {
        cart[product] = 1;
        totalPrices[product] =
            productlist.firstWhere((p) => p.name == product).price;
      }
      updateTotalCartItems(); // Update the total cart items
    });
  }

  void removeFromCart(String product) {
    setState(() {
      if (cart.containsKey(product)) {
        final currentQuantity = cart[product] ?? 0;
        if (currentQuantity > 1) {
          cart[product] = currentQuantity - 1;
          totalPrices[product] = (totalPrices[product] ?? 0) -
              (productlist.firstWhere((p) => p.name == product).price);
        } else {
          cart.remove(product);
          totalPrices.remove(product);
        }
        updateTotalCartItems(); // Update the total cart items
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: badges.Badge(
                  badgeContent: Text(totalCartItems.toString(),
                      style: const TextStyle(color: Colors.white)),
                  position: badges.BadgePosition.topEnd(top: -10, end: 0),
                  badgeStyle: badges.BadgeStyle(
                    shape: badges.BadgeShape.circle,
                    badgeColor: const Color.fromARGB(255, 226, 48, 48),
                    padding: const EdgeInsets.all(5),
                    borderRadius: BorderRadius.circular(4),
                    elevation: 0,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartItemPage(
                            cart: cart,
                            removeFromCart: removeFromCart,
                            products: productlist,
                            addToCart: addToCart,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: productlist.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                            width: 100,
                            height: 100,
                            child: Image.memory(
                                base64Decode(productlist[index].imageAsset))),
                        Expanded(
                          child: ListTile(
                            title: Text(productlist[index].name),
                            subtitle: Text(
                              'Price: \$${productlist[index].price.toStringAsFixed(2)}',
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                addToCart(productlist[index].name);
                              },
                              child: const Text("Add to Cart"),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Product {
  final String name;
  final double price;
  final String imageAsset;

  Product(this.name, this.price, this.imageAsset);
}
