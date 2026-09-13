import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

import '../controller/auth_controller.dart';
import '../models/api_response.dart';

class ApiCaller {
  static const Duration _timeout = Duration(seconds: 20);

  static Map<String, dynamic>? _decodeMap(String body) {
    if (body.trim().isEmpty) return null;
    final decoded = jsonDecode(body);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  static String _message(Map<String, dynamic>? data, String fallback) {
    final value = data?['message'] ?? data?['data'] ?? data?['error'];
    if (value is String && value.trim().isNotEmpty) return value;
    return fallback;
  }

  /// GET Method
  static Future<ApiResponse> getRequest({required String url}) async {
    try {
      final response = await get(
        Uri.parse(url),
        headers: {'token': AuthController.userToken ?? ''},
      ).timeout(_timeout);

      final decodedData = _decodeMap(response.body);
      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;

      return ApiResponse(
        rensponseCode: response.statusCode,
        responseData: decodedData,
        isSuccess: isSuccess,
        errorMessage: isSuccess
            ? null
            : _message(decodedData, 'Request failed (${response.statusCode}).'),
      );
    } on TimeoutException {
      return ApiResponse(
        rensponseCode: -1,
        responseData: null,
        isSuccess: false,
        errorMessage: 'The request timed out. Please check your connection and try again.',
      );
    } catch (e) {
      return ApiResponse(
        rensponseCode: -1,
        responseData: null,
        isSuccess: false,
        errorMessage:
            'Network error. Please check your connection and try again.',
      );
    }
  }

  /// POST Method
  static Future<ApiResponse> postRequest({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'token': AuthController.userToken ?? '',
        },
        body: body == null ? null : jsonEncode(body),
      ).timeout(_timeout);

      final decodedData = _decodeMap(response.body);
      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;

      return ApiResponse(
        rensponseCode: response.statusCode,
        responseData: decodedData,
        isSuccess: isSuccess,
        errorMessage: isSuccess
            ? null
            : _message(decodedData, 'Request failed (${response.statusCode}).'),
      );
    } on TimeoutException {
      return ApiResponse(
        rensponseCode: -1,
        responseData: null,
        isSuccess: false,
        errorMessage: 'The request timed out. Please check your connection and try again.',
      );
    } catch (e) {
      return ApiResponse(
        rensponseCode: -1,
        responseData: null,
        isSuccess: false,
        errorMessage:
            'Network error. Please check your connection and try again.',
      );
    }
  }
}
