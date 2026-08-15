import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shop/config/app_config.dart';
import 'package:shop/core/network/medusa_api_exception.dart';

class MedusaClient {
  MedusaClient({
    String? baseUrl,
    String? publishableKey,
    http.Client? httpClient,
  })  : _baseUrl = (baseUrl ?? AppConfig.medusaBaseUrl).trim(),
        _publishableKey =
            (publishableKey ?? AppConfig.medusaPublishableKey).trim(),
        _httpClient = httpClient ?? http.Client();

  final String _baseUrl;
  final String _publishableKey;
  final http.Client _httpClient;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    return _request(
      'GET',
      path,
      queryParameters: queryParameters,
    );
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
  }) {
    return _request(
      'POST',
      path,
      body: body,
      queryParameters: queryParameters,
    );
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    return _request(
      'DELETE',
      path,
      queryParameters: queryParameters,
    );
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
  }) async {
    final uri = _buildUri(path, queryParameters: queryParameters);
    final encodedBody = body == null ? null : jsonEncode(body);

    late final http.Response response;
    if (method == 'GET') {
      response = await _httpClient.get(uri, headers: _headers);
    } else if (method == 'POST') {
      response = await _httpClient.post(
        uri,
        headers: _headers,
        body: encodedBody,
      );
    } else if (method == 'DELETE') {
      response = await _httpClient.delete(uri, headers: _headers);
    } else {
      throw ArgumentError.value(method, 'method', 'Unsupported HTTP method');
    }

    Map<String, dynamic> responseBody = const {};
    if (response.body.isNotEmpty) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        responseBody = Map<String, dynamic>.from(decoded);
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MedusaApiException(
        statusCode: response.statusCode,
        message: responseBody['message']?.toString() ??
            'Medusa request failed with status ${response.statusCode}.',
      );
    }

    return responseBody;
  }

  Map<String, String> get _headers {
    if (_publishableKey.isEmpty) {
      throw StateError(
        'MEDUSA_PUBLISHABLE_KEY is required. Pass it with --dart-define.',
      );
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'x-publishable-api-key': _publishableKey,
    };
  }

  Uri _buildUri(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    if (_baseUrl.isEmpty) {
      throw StateError(
        'MEDUSA_BASE_URL is required. Pass it with --dart-define.',
      );
    }

    final base = Uri.parse(_baseUrl);
    final basePath = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;
    final endpoint = path.startsWith('/') ? path : '/$path';

    return base.replace(
      path: '$basePath$endpoint',
      queryParameters: queryParameters,
    );
  }
}
