import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uhpos/components/cart.dart';
import 'package:uhpos/repository/customhelper.dart';
import 'package:uhpos/repository/database.dart';
import 'package:uhpos/repository/receipt.dart';

class Email {
  Future<String> sendEmail(
      List<Map<String, dynamic>> itemlist,
      int detailid,
      String cashier,
      String recipient,
      String paymenttype,
      String referenceid) async {
    DatabaseHelper dh = DatabaseHelper();
    Helper helper = Helper();
    CSS css = CSS();

    String id = '';
    String posname = '';
    String serial = '';
    String min = '';
    String ptu = '';

    String storeid = '';
    String storename = '';
    String tin = '';
    List<String> address = [];
    String logo = '';
    String username = '';
    String password = '';
    String emailserver = '';

    String date = helper.GetCurrentDatetime();

    List<Items> items = [];

    Database db = await dh.database;
    List<Map<String, dynamic>> posconfig = await db.query('pos');
    for (var pos in posconfig) {
      //  print(pos);
      id = pos['posid'].toString();
      posname = pos['posname'];
      serial = pos['serial'];
      min = pos['min'];
      ptu = 'PTU: ${pos['ptu']}';
    }

    List<Map<String, dynamic>> storeconfig = await db.query('store');
    for (var store in storeconfig) {
      //  print(store);
      storeid = store['storeid'].toString();
      storename = store['storename'];
      tin = 'VAT REG TIN: ${store['tin']}';
      address = store['address'].toString().split(',').toList();
      logo = store['logo'];
    }

    List<Map<String, dynamic>> emailconfig = await db.query('email');
    for (var email in emailconfig) {
      print(email);

      username = email['emailaddress'];
      password = email['emailpassword'];
      emailserver = email['emailserver'];
    }

    for (int index = 0; index < itemlist.length; index++) {
      int quantity = itemlist[index]['quantity'];
      double price = itemlist[index]['price'];
      double subtotal = quantity.toDouble() * price.toDouble();

      items.add(Items(itemlist[index]['name'], quantity, price, subtotal));
    }

    String details = '';
    if (paymenttype != 'CASH') {
      if (paymenttype == 'UH POINTS') {
        details =
          'Cashier: $cashier<br>POS ID:$id<br>OR#: $detailid<br>Date: $date<br>Payment Type: $paymenttype<br>Customer ID. #: $referenceid';
      } else {
        details =
            'Cashier: $cashier<br>POS ID:$id<br>OR#: $detailid<br>Date: $date<br>Payment Type: $paymenttype<br>Ref. #: $referenceid';
      }
    } else {
      details =
          'Cashier: $cashier<br>POS ID:$id<br>OR#: $detailid<br>Date: $date<br>Payment Type: $paymenttype';
    }

    double total = 0;
    String itemdetails = '';
    for (var item in items) {
      itemdetails += """
          <tr>
            <td>${item.name} x ${item.quantity} </td>
            <td class="alignright">${item.price}</td>
            <td class="alignright">${item.subtotal} </td>
          </tr>
        """;

      total += item.subtotal;
    }

        String location = '';
    for (String addr in address) {
      location += '$addr ';
    }

    // final directory = await getTemporaryDirectory();
    // String filepath = '${directory.path}/$detailid.pdf';
    // final pdfFile = File(filepath);

    final smtpServer = SmtpServer(emailserver,
        username: username, password: password, port: 587, ssl: false);

    final message = Message()
      ..from = Address(username)
      ..recipients.add(recipient)
      ..subject = '$storename - OR#:$detailid [E-Receipt]'
      ..html = '''
<html>
<head>
${css.css()}
</head>
<body>

<table class="body-wrap">
    <tbody><tr>
        <td></td>
        <td class="container" width="600">
            <div class="content">
                <table class="main" width="100%" cellpadding="0" cellspacing="0">
                    <tbody><tr>
                        <td class="content-wrap aligncenter">
                            <table width="100%" cellpadding="0" cellspacing="0">
                                <tbody>
                                <tr>
                                    <td class="content-block">
                                        <h2>$storename</h2>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="content-block">
                                        <table class="invoice">
                                            <tbody>
                                            <tr>
                                                <td>$details</td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <table class="invoice-items" cellpadding="0" cellspacing="10">
                                                        <thead>
                                                          <th>Item</th>
                                                          <th>Price</th>
                                                          <th>Subtotal</th>
                                                        </thead>
                                                        <tbody>
                                                          $itemdetails
                                                          <tr class="total">
                                                              <td class="aligncenter" width="60%">Total</td>
                                                              <td></td>
                                                              <td class="alignright">${helper.formatAsCurrency(total)}</td>
                                                          </tr>
                                                        </tbody>
                                                    </table>
                                                </td>
                                            </tr>
                                        </tbody></table>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="content-block">
                                     $location
                                    </td>
                                </tr>
                                <tr>
                                  <td>Thank you for being our valued customer. We hope our product will meet your expectations. Let us know if you have any questions.</td>
                                </tr>
                            </tbody></table>
                        </td>
                    </tr>
                </tbody></table>
                <div class="footer">
                    <table width="100%">
                        <tbody>
                        <tr>
                            <td class="aligncenter content-block">Questions? Email <a href="mailto:">hideouturban@gmail.com</a></td>
                        </tr>
                    </tbody></table>
                </div></div>
        </td>
        <td></td>
    </tr>
</tbody></table>
</body>
</html> 
''';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ${sendReport.toString()}');

      // await helper.deleteFile(filepath);

      return 'success';
    } on MailerException catch (e) {
      print('Message not sent. Error: ${e.message}');

      return e.message;
    }
  }
}

class CSS {
  String css() {
    return """
<style>
/* -------------------------------------
    GLOBAL
    A very basic CSS reset
------------------------------------- */
* {
    margin: 0;
    padding: 0;
    font-family: "Helvetica Neue", "Helvetica", Helvetica, Arial, sans-serif;
    box-sizing: border-box;
    font-size: 14px;
}

img {
    max-width: 100%;
}

body {
    -webkit-font-smoothing: antialiased;
    -webkit-text-size-adjust: none;
    width: 100% !important;
    height: 100%;
    line-height: 1.6;
}

/* Let's make sure all tables have defaults */
table td {
    vertical-align: top;
}

/* -------------------------------------
    BODY & CONTAINER
------------------------------------- */
body {
    background-color: #f6f6f6;
}

.body-wrap {
    background-color: #f6f6f6;
    width: 100%;
}

.container {
    display: block !important;
    max-width: 600px !important;
    margin: 0 auto !important;
    /* makes it centered */
    clear: both !important;
}

.content {
    max-width: 800px;
    margin: 0 auto;
    display: block;
    padding: 20px;
}

/* -------------------------------------
    HEADER, FOOTER, MAIN
------------------------------------- */
.main {
    background: #fff;
    border: 1px solid #e9e9e9;
    border-radius: 3px;
}

.content-wrap {
    padding: 20px;
}

.content-block {
    padding: 0 0 20px;
}

.header {
    width: 100%;
    margin-bottom: 20px;
}

.footer {
    width: 100%;
    clear: both;
    color: #999;
    padding: 20px;
}
.footer a {
    color: #999;
}
.footer p, .footer a, .footer unsubscribe, .footer td {
    font-size: 12px;
}

/* -------------------------------------
    TYPOGRAPHY
------------------------------------- */
h1, h2, h3 {
    font-family: "Helvetica Neue", Helvetica, Arial, "Lucida Grande", sans-serif;
    color: #000;
    margin: 40px 0 0;
    line-height: 1.2;
    font-weight: 400;
}

h1 {
    font-size: 32px;
    font-weight: 500;
}

h2 {
    font-size: 24px;
}

h3 {
    font-size: 18px;
}

h4 {
    font-size: 14px;
    font-weight: 600;
}

p, ul, ol {
    margin-bottom: 10px;
    font-weight: normal;
}
p li, ul li, ol li {
    margin-left: 5px;
    list-style-position: inside;
}

/* -------------------------------------
    LINKS & BUTTONS
------------------------------------- */
a {
    color: #1ab394;
    text-decoration: underline;
}

.btn-primary {
    text-decoration: none;
    color: #FFF;
    background-color: #1ab394;
    border: solid #1ab394;
    border-width: 5px 10px;
    line-height: 2;
    font-weight: bold;
    text-align: center;
    cursor: pointer;
    display: inline-block;
    border-radius: 5px;
    text-transform: capitalize;
}

/* -------------------------------------
    OTHER STYLES THAT MIGHT BE USEFUL
------------------------------------- */
.last {
    margin-bottom: 0;
}

.first {
    margin-top: 0;
}

.aligncenter {
    text-align: center;
}

.alignright {
    text-align: right;
}

.alignleft {
    text-align: left;
}

.clear {
    clear: both;
}

/* -------------------------------------
    ALERTS
    Change the class depending on warning email, good email or bad email
------------------------------------- */
.alert {
    font-size: 16px;
    color: #fff;
    font-weight: 500;
    padding: 20px;
    text-align: center;
    border-radius: 3px 3px 0 0;
}
.alert a {
    color: #fff;
    text-decoration: none;
    font-weight: 500;
    font-size: 16px;
}
.alert.alert-warning {
    background: #f8ac59;
}
.alert.alert-bad {
    background: #ed5565;
}
.alert.alert-good {
    background: #1ab394;
}

/* -------------------------------------
    INVOICE
    Styles for the billing table
------------------------------------- */
.invoice {
    margin: 40px auto;
    text-align: left;
    width: 80%;
}
.invoice td {
    padding: 5px 0;
}
.invoice .invoice-items {
    width: 100%;
}
.invoice .invoice-items td {
    border-top: #eee 1px solid;
}
.invoice .invoice-items .total td {
    border-top: 2px solid #333;
    border-bottom: 2px solid #333;
    font-weight: 700;
}

/* -------------------------------------
    RESPONSIVE AND MOBILE FRIENDLY STYLES
------------------------------------- */
@media only screen and (max-width: 640px) {
    h1, h2, h3, h4 {
        font-weight: 600 !important;
        margin: 20px 0 5px !important;
    }

    h1 {
        font-size: 22px !important;
    }

    h2 {
        font-size: 18px !important;
    }

    h3 {
        font-size: 16px !important;
    }

    .container {
        width: 100% !important;
    }

    .content, .content-wrap {
        padding: 10px !important;
    }

    .invoice {
        width: 100% !important;
    }
}
</style>
    """;
  }
}
