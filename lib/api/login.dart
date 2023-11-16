import 'dart:convert';

import '../config.dart';
import 'package:http/http.dart' as http;

class LoginAPI {
  Future<Map<String, dynamic>> getLogin(
      String username, String password) async {
    final url = Uri.parse('${Config.apiUrl}${Config.loginDAPI}');
    final response = await http
        .post(url, body: {'username': username, 'password': password});
    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }
}
