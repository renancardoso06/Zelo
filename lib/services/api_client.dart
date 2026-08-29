// Cliente HTTP central para a API do backend Zelo (Spring Boot).
//
// Responsabilidades:
// - Resolver a base URL (configurável via --dart-define=API_BASE_URL=...,
//   com fallback automático para o emulador Android).
// - Injetar "Authorization: Bearer {token}" em toda chamada autenticada,
//   buscando o token salvo localmente.
// - Traduzir respostas de erro do backend (400 de validação, 401, 403,
//   404, 422, 500 — ver GlobalExceptionHandler no backend) em ApiException,
//   com mensagem pronta para exibir ao usuário.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, String>? fieldErrors;

  const ApiException(this.statusCode, this.message, {this.fieldErrors});

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  static const String tokenKey = 'authToken';

  // Permite sobrescrever em tempo de build/execução:
  // flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8080
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    if (kIsWeb) return 'http://localhost:8080';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

  Future<dynamic> get(String path, {bool auth = true}) =>
      _send('GET', path, auth: auth);

  Future<dynamic> post(String path, {Object? body, bool auth = true}) =>
      _send('POST', path, body: body, auth: auth);

  Future<String?> _readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<Map<String, String>> _buildHeaders(bool auth) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _readToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    bool auth = true,
  }) async {
    final headers = await _buildHeaders(auth);
    final uri = Uri.parse('$baseUrl$path');
    final encodedBody = body != null ? jsonEncode(body) : null;

    http.Response response;
    try {
      switch (method) {
        case 'GET':
          response =
              await http.get(uri, headers: headers).timeout(const Duration(seconds: 12));
          break;
        case 'POST':
          response = await http
              .post(uri, headers: headers, body: encodedBody)
              .timeout(const Duration(seconds: 12));
          break;
        default:
          throw UnsupportedError('Método HTTP não suportado: $method');
      }
    } on TimeoutException {
      throw const ApiException(
        0,
        'O servidor demorou demais para responder. Verifique se o backend está rodando.',
      );
    } on SocketException {
      throw const ApiException(
        0,
        'Não foi possível conectar ao servidor. Verifique sua conexão e o endereço da API.',
      );
    }

    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    final status = response.statusCode;
    final bodyText = response.body;
    final decoded = bodyText.isNotEmpty ? jsonDecode(utf8.decode(response.bodyBytes)) : null;

    if (status >= 200 && status < 300) {
      return decoded;
    }

    String message = 'Erro inesperado ao falar com o servidor (HTTP $status)';
    Map<String, String>? fieldErrors;

    if (decoded is Map<String, dynamic>) {
      message = decoded['message'] as String? ?? message;
      final rawFieldErrors = decoded['fieldErrors'];
      if (rawFieldErrors is Map) {
        fieldErrors = rawFieldErrors
            .map((key, value) => MapEntry(key.toString(), value.toString()));
      }
    }

    throw ApiException(status, message, fieldErrors: fieldErrors);
  }
}
