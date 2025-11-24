import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class AuthService {
  final http.Client client;
  AuthService({http.Client? client}) : client = client ?? http.Client();

  Future<Map<String, dynamic>> login(String username, String password) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}');
    final resp = await client.post(uri, body: {'username': username, 'password': password});
    return json.decode(resp.body) as Map<String, dynamic>;
  }
}
