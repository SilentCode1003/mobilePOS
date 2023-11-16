import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:pdf/pdf.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:uhpos/repository/customhelper.dart';
import 'package:uhpos/repository/database.dart';
import 'package:pdf/widgets.dart' as pw;

class Receipt {
  double total;
  List<Map<String, dynamic>> itemlist = [];
  double change;
  double amounttender;
  String cashier;

  Receipt(
      this.itemlist, this.total, this.change, this.amounttender, this.cashier);

  DatabaseHelper dh = DatabaseHelper();
  Helper helper = Helper();

  String formatAsCurrency(double value) {
    return toCurrencyString(
      value.toString(), mantissaLength: 2,
      // leadingSymbol: CurrencySymbols.
    );
  }

  Future<Uint8List> printReceipt() async {
    // String id = '';
    String posname = '';
    String serial = '';
    String min = '';
    String ptu = '';

    // String storeid = '';
    String storename = '';
    String address = '';
    String contact = '';
    List<String> logo = [];
    String message = '';

    List<Items> items = [];

    PdfPageFormat format = PdfPageFormat.roll80;
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);

    Database db = await dh.database;
    List<Map<String, dynamic>> posconfig = await db.query('pos');
    for (var pos in posconfig) {
      // id = pos['posid'].toString();
      posname = pos['posname'];
      serial = pos['serial'].toString();
      min = pos['min'].toString();
      ptu = pos['ptu'].toString();
    }

    List<Map<String, dynamic>> storeconfig = await db.query('store');
    for (var store in storeconfig) {
      // storeid = store['storeid'].toString();
      storename = store['storename'];
      address = store['address'];
      contact = store['contact'].toString();
      message = store['message'];
      logo = utf8.decode(base64.decode(store['logo'])).split('<svg');
    }

    for (int index = 0; index < itemlist.length; index++) {
      int quantity = itemlist[index]['quantity'];
      double price = itemlist[index]['price'];
      double subtotal = quantity.toDouble() * price.toDouble();

      items.add(Items(itemlist[index]['name'], quantity, price, subtotal));
    }

    pdf.addPage(pw.Page(
        pageFormat: format,
        build: (context) {
          return (pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.SizedBox(
                    height: 40,
                    width: 40,
                    child: pw.Flexible(
                        child: pw.SvgImage(svg: '<svg ${logo[1]}'))),
                pw.Text(storename,
                    style: pw.TextStyle(
                        fontSize: 8, fontWeight: pw.FontWeight.bold)),
                pw.Text(address,
                    style: pw.TextStyle(
                        fontSize: 8, fontWeight: pw.FontWeight.bold)),
                pw.Text(contact,
                    style: pw.TextStyle(
                        fontSize: 8, fontWeight: pw.FontWeight.bold)),
                pw.Divider(thickness: 2),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(
                          width: 100,
                          child: pw.Text(
                            helper.GetCurrentDatetime(),
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          )),
                    ]),
                pw.SizedBox(height: 5),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Container(
                          width: 100,
                          child: pw.Text(
                            'POS: $posname',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          )),
                      pw.Container(
                          width: 100,
                          child: pw.Text(
                            'SN: $serial',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          )),
                    ]),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Cashier: $cashier',
                          style: pw.TextStyle(
                              fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    ]),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('MIN.: $min',
                          style: pw.TextStyle(
                              fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    ]),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('PTU: $ptu',
                          style: pw.TextStyle(
                              fontSize: 8, fontWeight: pw.FontWeight.bold))
                    ]),
                pw.Divider(thickness: 2),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                          width: 100,
                          child: pw.Text(
                            'Description',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          )),
                      pw.Container(
                          width: 100,
                          child: pw.Text(
                            'Amount',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          )),
                    ]),
                pw.SizedBox(height: 5),
                for (var item in items)
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          width: 100,
                          child: pw.Text('${item.name} @ ${item.quantity}',
                              style: pw.TextStyle(
                                  fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Container(
                            width: 100,
                            child: pw.Text(
                              formatAsCurrency(item.subtotal),
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ))
                      ]),
                pw.Divider(thickness: 2),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Container(
                          width: 100,
                          child: pw.Text(
                            'Cash Tender:',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          )),
                      pw.Container(
                          width: 100,
                          child: pw.Text(
                            formatAsCurrency(amounttender),
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          )),
                    ]),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Container(
                          width: 100,
                          child: pw.Text(
                            'Total Amount:',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          )),
                      pw.Container(
                          width: 100,
                          child: pw.Text(
                            formatAsCurrency(total),
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          )),
                    ]),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Container(
                          width: 100,
                          child: pw.Text(
                            'Change:',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          )),
                      pw.Container(
                          width: 100,
                          child: pw.Text(
                            formatAsCurrency(change),
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          )),
                    ]),
                pw.Divider(thickness: 2),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(message,
                          style: pw.TextStyle(
                              fontSize: 8, fontWeight: pw.FontWeight.bold))
                    ])
              ]));
        }));

    return pdf.save();
  }
}

class Items {
  final String name;
  final int quantity;
  final double price;
  final double subtotal;

  Items(this.name, this.quantity, this.price, this.subtotal);
}
