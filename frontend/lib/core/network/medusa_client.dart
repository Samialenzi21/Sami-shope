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
  }) async {
    final uri = _buildUri(path, queryParameters: queryParameters);
    final response = await _httpClient.get(uri, headers: _headers);

    Map<String, dynamic> body = const {};
    if (response.body.isNotEmpty) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        body = decoded;
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MedusaApiException(
        statusCode: response.statusCode,
        message: body['message']?.toString() ??
            'Medusa request failed with status ${response.statusCode}.',
      );
    }

    return body;
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
