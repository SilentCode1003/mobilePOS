import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:uhpos/api/product.dart';
import 'package:uhpos/api/salesdetail.dart';
import 'package:uhpos/components/cartitem.dart';
import 'package:uhpos/components/login.dart';
import 'package:uhpos/components/settings.dart';

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
        productlist.add(Product(
            data['description'], data['price'].toDouble(), data['image']));
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
              leading: Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // Add your action when Settings is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
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
                            subtitle: Text(
                              'Price: ₱${productlist[index].price.toStringAsFixed(2)}',
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

//Product Class
class Product {
  final String name;
  final double price;
  final String imageAsset;

  Product(this.name, this.price, this.imageAsset);
}
