import 'dart:convert';

import '../config.dart';
import 'package:http/http.dart' as http;

class PosAPI {
  Future<Map<String, dynamic>> getPOS(String posid) async {
    final url = Uri.parse('${Config.apiUrl}${Config.posAPI}');
    final response = await http.post(url, body: {
      'posid': posid,
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
