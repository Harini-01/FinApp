import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  // TODO: Replace with your Firebase project ID
  static const String baseUrl =
      'http://127.0.0.1:5001/finapp-d7e39/us-central1';

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'), // Updated endpoint
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(json.decode(response.body)['error']);
    }
  }

  static Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
    String trackingMethod = 'manual',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/addUser'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'trackingMethod': trackingMethod,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(json.decode(response.body)['error']);
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/updateProfile'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
        ...data,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(json.decode(response.body)['error']);
    }
  }
}
