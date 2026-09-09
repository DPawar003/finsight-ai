import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../core/graphql_client.dart';

class ReceiptScanResult {
  final double? amount;
  final String? description;
  final String? rawText;

  ReceiptScanResult({this.amount, this.description, this.rawText});

  factory ReceiptScanResult.fromJson(Map<String, dynamic> json) {
    return ReceiptScanResult(
      amount: json['amount'] != null
          ? (json['amount'] as num).toDouble()
          : null,
      description: json['description'] as String?,
    );
  }
}

class ReceiptRepository {
  // FastAPI running inside Docker
  static const String _baseUrl = 'http://192.168.1.103:8000';

  Future<ReceiptScanResult> scanReceipt(String imagePath) async {
    print('');
    print('==========================================');
    print('          RECEIPT SCAN STARTED');
    print('==========================================');

    // Check image exists
    final imageFile = File(imagePath);

    if (!await imageFile.exists()) {
      throw Exception('Image file does not exist: $imagePath');
    }

    final fileSize = await imageFile.length();

    print('IMAGE PATH: $imagePath');
    print('IMAGE EXISTS: true');
    print('IMAGE SIZE: $fileSize bytes');

    // Get JWT token
    final token = await GraphQLConfig.getToken();

    print('TOKEN EXISTS: ${token != null && token.isNotEmpty}');

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }

    // Build endpoint
    final uri = Uri.parse('$_baseUrl/receipts/scan');

    print('BASE URL: $_baseUrl');
    print('REQUEST URL: $uri');

    // Determine image type
    final extension = imagePath.split('.').last.toLowerCase();

    String mimeSubtype;

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        mimeSubtype = 'jpeg';
        break;

      case 'png':
        mimeSubtype = 'png';
        break;

      default:
        throw Exception(
          'Unsupported image format: .$extension\n'
          'Please select JPG, JPEG, or PNG.',
        );
    }

    print('FILE EXTENSION: .$extension');
    print('CONTENT TYPE: image/$mimeSubtype');

    try {
      print('');
      print('Creating multipart request...');

      final request = http.MultipartRequest('POST', uri);

      // JWT authentication
      request.headers['Authorization'] = 'Bearer $token';

      request.headers['Accept'] = 'application/json';

      print('AUTHORIZATION HEADER: Bearer <token>');
      print('FIELD NAME: file');

      // Add image
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        imagePath,
        contentType: MediaType('image', mimeSubtype),
      );

      request.files.add(multipartFile);

      print('FILE NAME: ${multipartFile.filename}');
      print('FILE LENGTH: ${multipartFile.length}');
      print('REQUEST METHOD: POST');

      print('');
      print('------------------------------------------');
      print('SENDING REQUEST TO DOCKER...');
      print('URL: $uri');
      print('------------------------------------------');

      final streamedResponse = await request.send();

      print('');
      print('RESPONSE RECEIVED FROM DOCKER');

      final response = await http.Response.fromStream(streamedResponse);

      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('==========================================');
      print('          RECEIPT SCAN FINISHED');
      print('==========================================');
      print('');

      if (response.statusCode != 200) {
        String errorMessage;

        try {
          final body = jsonDecode(response.body);
          errorMessage = body['detail']?.toString() ?? 'Receipt scan failed';
        } catch (_) {
          errorMessage = response.body;
        }

        throw Exception(
          'Receipt scan failed '
          '(${response.statusCode}): $errorMessage',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid response received from receipt API.');
      }

      return ReceiptScanResult.fromJson(decoded);
    } on SocketException catch (e) {
      print('');
      print('==========================================');
      print('DOCKER CONNECTION ERROR');
      print('==========================================');
      print('Could not connect to: $uri');
      print('ERROR: $e');
      print('');
      print('Check that:');
      print('1. Docker container is running');
      print('2. Port 8000 is mapped');
      print('3. PC IP is 192.168.1.103');
      print('4. Phone/emulator can reach the PC');
      print('==========================================');

      throw Exception('Cannot connect to backend at $uri');
    } catch (e) {
      print('');
      print('==========================================');
      print('RECEIPT SCAN ERROR');
      print('==========================================');
      print(e);
      print('==========================================');

      rethrow;
    }
  }
}
