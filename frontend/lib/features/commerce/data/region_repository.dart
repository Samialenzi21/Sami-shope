import 'package:shop/core/network/medusa_client.dart';

class RegionRepository {
  RegionRepository({MedusaClient? client}) : _client = client ?? MedusaClient();

  final MedusaClient _client;
  String? _saudiRegionId;

  Future<String> getSaudiRegionId() async {
    if (_saudiRegionId != null) {
      return _saudiRegionId!;
    }

    final response = await _client.get(
      '/store/regions',
      queryParameters: const {'limit': '100'},
    );

    final rawRegions = response['regions'];
    if (rawRegions is! List) {
      throw const FormatException('Medusa regions response is invalid.');
    }

    for (final rawRegion in rawRegions.whereType<Map>()) {
      final region = Map<String, dynamic>.from(rawRegion);
      if (region['currency_code']?.toString().toLowerCase() == 'sar') {
        final id = region['id']?.toString();
        if (id != null && id.isNotEmpty) {
          _saudiRegionId = id;
          return id;
        }
      }
    }

    throw StateError('Saudi Arabia SAR region was not found in Medusa.');
  }
}
