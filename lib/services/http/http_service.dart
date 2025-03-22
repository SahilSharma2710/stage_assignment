import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpService {
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  HttpService({
    required this.baseUrl,
    this.defaultHeaders = const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  });

  // GET request
  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {...defaultHeaders, ...?headers},
      );

      return _processResponse(response);
    } catch (e) {
      throw Exception('GET request failed: $e');
    }
  }

  // POST request
  Future<dynamic> post(String endpoint, dynamic body,
      {Map<String, String>? headers}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {...defaultHeaders, ...?headers},
        body: jsonEncode(body),
      );

      return _processResponse(response);
    } catch (e) {
      throw Exception('POST request failed: $e');
    }
  }

  // Process the response
  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Success response
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return null;
    } else {
      // Error response
      throw HttpException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }
  }
}

// Custom exception for HTTP errors
class HttpException implements Exception {
  final int statusCode;
  final String message;

  HttpException({required this.statusCode, required this.message});

  @override
  String toString() {
    return 'HttpException: Status Code: $statusCode, Message: $message';
  }
}
