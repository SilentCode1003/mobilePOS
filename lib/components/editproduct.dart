import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:uhpos/api/product.dart';
import 'package:image_picker/image_picker.dart';

class EditProductPage extends StatefulWidget {
  final String itemdescription;
  const EditProductPage({super.key, required this.itemdescription});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final TextEditingController _priceController = TextEditingController();
  String description = '';
  String image = '';
  String status = '';

  double cash = 0;

  File? _selectedImage;

  @override
  void initState() {
    setState(() {
      description = widget.itemdescription;
    });

    print(widget.itemdescription);

    _getproductinfo(description);
    super.initState();
  }

  Future<void> _getproductinfo(String description) async {
    try {
      final results = await ProductAPI().getProductInfo(description);
      final jsonData = json.encode(results['data']);

      setState(() {
        for (var data in json.decode(jsonData)) {
          int price = data['price'];
          double pricetotal = price.toDouble();

          image = data['image'];
          price = data['price'];
          description = data['description'];
          status = data['status'];

          _priceController.text = pricetotal.toStringAsFixed(2).toString();
        }
      });
    } catch (e) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('$e}'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'))
              ],
            );
          });
    }
  }

  Future<void> _updateproduct(
      String description, String image, String price, String status) async {
    try {
      // print('$description $image $price');
      final results =
          await ProductAPI().updateProduct(description, image, price, status);
      final jsonData = json.encode(results['data']);

      if (results['msg'] == 'success') {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Success'),
                content: const Text('Update successfull'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'))
                ],
              );
            });
      }
    } catch (e) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('$e}'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'))
              ],
            );
          });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        // Read the image file as bytes
        List<int> imageBytes = File(pickedFile.path).readAsBytesSync();

        // Encode the bytes to base64
        image = base64Encode(imageBytes);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit $description',
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: 200,
                height: 200,
                child: Image.memory(base64Decode(image))),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  _pickImage();
                },
                child: const Text('Browse',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w600))),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: _priceController,
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
                  borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                ),
                labelText: 'Price',
                labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                border: OutlineInputBorder(),
                hintText: 'Enter New Price',
                prefixIcon: Icon(Icons.store),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Container(
                height: 60,
                child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (status == "ACTIVE") {
                          status = 'INACTIVE';
                        } else if (status == "INACTIVE") {
                          status = 'ACTIVE';
                        }

                        print(status);
                      });
                    },
                    child: Text('$status',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600))))
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
          height: 80,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _updateproduct(description, image, cash.toString(), status);
              });
            },
            child: const Text(
              'Update',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
          )),
    );
  }
}
