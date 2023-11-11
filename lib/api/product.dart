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

  Future<Map<String, dynamic>> getAllProduct() async {
    final url = Uri.parse('${Config.apiUrl}${Config.getAllProductAPI}');
    final response = await http.get(url);

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }

  Future<Map<String, dynamic>> getProductInfo(String description) async {
    final url = Uri.parse('${Config.apiUrl}${Config.getProductInfoAPI}');
    final response = await http.post(url, body: {
      'description': description,
    });

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }

  Future<Map<String, dynamic>> updateProduct(
      String description, String image, String price) async {
    final url = Uri.parse('${Config.apiUrl}${Config.updateProductAPI}');
    final response = await http.post(url,
        body: {'description': description, 'image': image, 'price': price});

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }
}
