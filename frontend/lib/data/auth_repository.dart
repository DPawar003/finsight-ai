
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/graphql_client.dart';

class AuthRepository {
  // FastAPI running inside Docker
  // Docker maps container port 8000 -> host port 8000
  static const String _baseUrl = 'http://192.168.1.103:8000';

  Future<void> signup({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/signup');

    print('========== SIGNUP ==========');
    print('REQUEST URL: $uri');
    print('EMAIL: $email');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'full_name': fullName,
        }),
      );

      print('SIGNUP STATUS: ${response.statusCode}');
      print('SIGNUP RESPONSE: ${response.body}');
      print('============================');

      if (response.statusCode != 200) {
        try {
          final body = jsonDecode(response.body);
          throw Exception(body['detail'] ?? 'Signup failed');
        } catch (_) {
          throw Exception(
            'Signup failed (${response.statusCode}): ${response.body}',
          );
        }
      }
    } catch (e) {
      print('SIGNUP ERROR: $e');
      print('============================');
      rethrow;
    }
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/login');

    print('========== LOGIN ==========');
    print('REQUEST URL: $uri');
    print('EMAIL: $email');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'username': email,
          'password': password,
        },
      );

      print('LOGIN STATUS: ${response.statusCode}');
      print('LOGIN RESPONSE: ${response.body}');

      if (response.statusCode != 200) {
        try {
          final body = jsonDecode(response.body);
          throw Exception(body['detail'] ?? 'Login failed');
        } catch (_) {
          throw Exception(
            'Login failed (${response.statusCode}): ${response.body}',
          );
        }
      }

      final data = jsonDecode(response.body);
      final token = data['access_token'] as String;

      await GraphQLConfig.saveToken(token);

      print('TOKEN SAVED: true');
      print('===========================');

      return token;
    } catch (e) {
      print('LOGIN ERROR: $e');
      print('===========================');
      rethrow;
    }
  }

  Future<void> logout() async {
    await GraphQLConfig.deleteToken();
    print('LOGOUT: token deleted');
  }

  Future<String?> getStoredToken() async {
    final token = await GraphQLConfig.getToken();

    print(
      'STORED TOKEN EXISTS: ${token != null && token.isNotEmpty}',
    );

    return token;
  }
}
