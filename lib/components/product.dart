import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:uhpos/api/product.dart';
import 'package:uhpos/components/cart.dart';
import 'package:uhpos/components/editproduct.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Product> productlist = [];

  @override
  void initState() {
    super.initState();
    _getproductlist();
  }

  Future<void> _getproductlist() async {
    final results = await ProductAPI().getAllProduct();
    final jsonData = json.encode(results['data']);

    setState(() {
      for (var data in json.decode(jsonData)) {
        productlist.add(Product(
            data['description'], data['price'].toDouble(), data['image']));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProductPage(itemdescription:'${productlist[index].name}'),
                                  ),
                                );
                              },
                              child: const Text("Edit",style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
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
