import 'dart:convert';
import 'dart:io';

import '../config.dart';
import 'package:http/http.dart' as http;

class SalesDetailAPI {
  Future<Map<String, dynamic>> getdetailid(String posid) async {
    final url = Uri.parse('${Config.apiUrl}${Config.getActiveCategoryAPI}');
    final response = await http.post(url, body: {'posid': posid});

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }

  Future<Map<String, dynamic>> sendtransaction(
      double id,
      int posid,
      String cashier,
      String paymenttype,
      List<Map<String, dynamic>> details,
      double total) async {
    final url = Uri.parse('${Config.apiUrl}${Config.getActiveCategoryAPI}');
    final response = await http.post(url, body: {
      'id': id,
      'posid': posid,
      'cashier': cashier,
      'paymenttype': paymenttype,
      'details': details,
      'total': total,
    });

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }
}
