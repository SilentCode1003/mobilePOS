import 'dart:io';

import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:intl/intl.dart';

class Helper {
  String GetCurrentDatetime() {
    DateTime currentDateTime = DateTime.now();
    String formattedDateTime =
        DateFormat('yyyy-MM-dd HH:mm').format(currentDateTime);
    return formattedDateTime;
  }

  String formatAsCurrency(double value) {
    return toCurrencyString(
      value.toString(), mantissaLength: 2,
      // leadingSymbol: CurrencySymbols.
    );
  }

   Future<void> deleteFile(String filepath) async {
    try {
      File file = File(filepath);

      if (await file.exists()) {
        await file.delete();
      } else {
        print('File not found');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
