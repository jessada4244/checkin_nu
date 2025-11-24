
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class StudentService {
	final http.Client client;
	StudentService({http.Client? client}) : client = client ?? http.Client();

	Future<Map<String, dynamic>> sendQrData(Map<String, dynamic> payload) async {
		final uri = Uri.parse('${ApiConstants.baseUrl}/attendance/scan');
		final resp = await client.post(uri, body: json.encode(payload), headers: {'Content-Type': 'application/json'});
		return json.decode(resp.body) as Map<String, dynamic>;
	}

	Future<List<Map<String, dynamic>>> getHistory(String userId) async {
		final uri = Uri.parse('${ApiConstants.baseUrl}/attendance/history?user_id=$userId');
		final resp = await client.get(uri);
		final data = json.decode(resp.body);
		if (data is List) {
			return List<Map<String, dynamic>>.from(data);
		}
		return [];
	}
}
