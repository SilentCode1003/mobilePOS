import 'dart:convert';

import '../config.dart';
import 'package:http/http.dart' as http;

class ProductAPI {
  Future<Map<String, dynamic>> getProduct() async {
    final url = Uri.parse('${Config.apiUrl}${Config.getProductAPI}');
    final response = await http.get(url);

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }
}
