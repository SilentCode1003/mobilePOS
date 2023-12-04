import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:uhpos/api/product.dart';
import 'package:uhpos/api/salesdetail.dart';
import 'package:uhpos/components/cartitem.dart';
import 'package:uhpos/components/login.dart';
import 'package:uhpos/components/product.dart';
import 'package:uhpos/components/settings.dart';
import 'package:uhpos/components/syncing.dart';

class CartApp extends StatelessWidget {
  final User user;
  CartApp({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CartPage(
        user: user,
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  final User user;

  CartPage({super.key, required this.user});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Map<String, int> cart = {};
  int totalCartItems = 0;
  Map<String, double> totalPrices = {};

  List<Product> productlist = [];
  int detailid = 0;
  @override
  void initState() {
    super.initState();
    _getproductlist();
    _getdetailid();
    updateTotalCartItems();
  }

  Future<void> _getdetailid() async {
    final results = await SalesDetailAPI().getdetailid('1000');
    final jsonData = json.encode(results['data']);

    setState(() {
      for (var data in json.decode(jsonData)) {
        detailid = int.parse(data['detailid']) + 1;
      }
    });
  }

  Future<void> _getproductlist() async {
    final results = await ProductAPI().getProduct();
    final jsonData = json.encode(results['data']);

    setState(() {
      for (var data in json.decode(jsonData)) {
        productlist.add(Product(data['description'], data['price'].toDouble(),
            data['image'], data['quantity']));
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
      int current_quantity =
          productlist.firstWhere((p) => p.name == product).quantity;
      int cartitem_quatity = (cart[product] ?? 0) + 1;

      if (cartitem_quatity <= current_quantity) {
        print(cart[product]);
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
      } else {
        print('Sorry $product availability is $current_quantity');
        showDialog(
          barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Availability'),
                content:
                    Text('Sorry "$product" availability is $current_quantity'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK'))
                ],
              );
            });
      }
    });
  }

  void deductToCart(String product) {
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

  void removeToCart(String product) {
    setState(() {
      if (cart.containsKey(product)) {
        cart.remove(product);
        totalPrices.remove(product);
        updateTotalCartItems(); // Update the total cart items
      }
    });
  }

  void incrementDetailid() {
    detailid++;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Urban Hideout Cafe'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/cart');
              },
              icon: Icon(Icons.refresh)),
          SizedBox(
            width: double.minPositive,
          ),
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
                            deductToCart: deductToCart,
                            products: productlist,
                            addToCart: addToCart,
                            removeToCart: removeToCart,
                            detailid: detailid,
                            incrementid: incrementDetailid,
                            user: widget.user,
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.brown,
              ),
              child: Text(
                'Urban Hideout Cafe',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.food_bank),
              title: const Text('Products'),
              onTap: () {
                // Add your action when Settings is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductPage(
                      user: widget.user,
                    ),
                  ),
                );
              },
            ),
            SizedBox(
              height: 120,
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // Add your action when Settings is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SyncingPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                // Add your action when Settings is tapped
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
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
                            subtitle: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Price: ₱${productlist[index].price.toStringAsFixed(2)}',
                                ),
                                Text(
                                  'Availability: ${productlist[index].quantity}',
                                )
                              ],
                            ),
                            trailing: (productlist[index].quantity < 1)
                                ? null
                                : ElevatedButton(
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

//Product Class
class Product {
  final String name;
  final double price;
  final String imageAsset;
  final int quantity;

  Product(this.name, this.price, this.imageAsset, this.quantity);
}
