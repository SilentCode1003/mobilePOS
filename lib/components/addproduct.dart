import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:uhpos/api/product.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uhpos/components/login.dart';

class AddProductPage extends StatefulWidget {
  final User user;
  const AddProductPage({
    super.key,
    required this.user,
  });

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String description = '';
  String image = '';
  String status = '';
  double cash = 0;

  File? _selectedImage;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _addproduct() async {
    try {
      showDialog(
          context: context,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });

      String description = _descriptionController.text;
      String price = _priceController.text;
      String message = '';

      if (description == "") {
        message += "Description ";
      }
      if (price == "") {
        message += "Price ";
      }

      if (message != "") {
        Navigator.of(context).pop();
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Empty'),
                content:
                    Text('Do not leave blank inputs especially [$message]'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'OK',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              );
            });
      } else {
        final results = await ProductAPI().addProduct(
            description, image, cash.toString(), widget.user.fullname);
        final jsonData = json.encode(results['data']);

        if (results['msg'] == 'success') {
          Navigator.of(context).pop();
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Success'),
                  content: Text('Added new product $description'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'))
                  ],
                );
              });
        } else {
          Navigator.of(context).pop();
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Exist'),
                  content: Text('Product [$description] already exist'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'))
                  ],
                );
              });
        }
      }
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Error"),
              content: Text('Error: $e'),
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
          'Add New Product',
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
              controller: _descriptionController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                ),
                labelText: 'Item Description',
                labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                border: OutlineInputBorder(),
                hintText: 'Enter Item Description',
                prefixIcon: Icon(Icons.food_bank),
              ),
            ),
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
                prefixIcon: Icon(Icons.monetization_on),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
          height: 80,
          child: ElevatedButton(
            onPressed: () {
              _addproduct();
            },
            child: const Text(
              'Add',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
          )),
    );
  }
}
