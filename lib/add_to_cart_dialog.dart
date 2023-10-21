// import 'package:flutter/material.dart';
// import 'package:smallprojectpos/dashboard.dart';

// class AddToCartDialog extends StatefulWidget {
//   @override
//   _AddToCartDialogState createState() => _AddToCartDialogState();
// }

// class _AddToCartDialogState extends State<AddToCartDialog> {
//   TextEditingController quantityController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text('Add to Cart'),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: <Widget>[
//           Text('Enter the quantity:'),
//           TextField(
//             controller: quantityController,
//             keyboardType: TextInputType.number, // Allow only numeric input
//           ),
//         ],
//       ),
//       actions: <Widget>[
//         TextButton(
//           onPressed: () {
//             Navigator.of(context).pop(); // Close the dialog
//           },
//           child: Text('Cancel'),
//         ),
//         TextButton(
//           onPressed: () {
//             String quantityText = quantityController.text;
//             if (quantityText.isNotEmpty) {
//               int quantity = int.tryParse(quantityText) ?? 0;
//               if (quantity > 0) {
//                 // Add the entered quantity to the cart
//                 setState(() {
//                   cart.add(Product('Selected Product', 0.0, quantity: quantity));
//                 });
//                 Navigator.of(context).pop(); // Close the dialog
//               }
//             }
//           },
//           child: Text('Add to Cart'),
//         ),
//       ],
//     );
//   }
// }
