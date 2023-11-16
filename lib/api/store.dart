import 'dart:convert';

import '../config.dart';
import 'package:http/http.dart' as http;

class StoreAPI {
  Future<Map<String, dynamic>> getStore(String storeid) async {
    final url = Uri.parse('${Config.apiUrl}${Config.storeAPI}');
    final response = await http.post(url, body: {
      'storeid': storeid,
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
