import 'package:shop/core/network/medusa_client.dart';
import 'package:shop/features/catalog/data/models/store_product.dart';
import 'package:shop/features/commerce/data/region_repository.dart';

class ProductRepository {
  ProductRepository({
    MedusaClient? client,
    RegionRepository? regionRepository,
  })  : _client = client ?? MedusaClient(),
        _regionRepository = regionRepository ?? RegionRepository(client: client);

  final MedusaClient _client;
  final RegionRepository _regionRepository;

  Future<List<StoreProduct>> listProducts({int limit = 20}) async {
    final regionId = await _regionRepository.getSaudiRegionId();
    final response = await _client.get(
      '/store/products',
      queryParameters: {
        'limit': '$limit',
        'region_id': regionId,
      },
    );

    final rawProducts = response['products'];
    if (rawProducts is! List) {
      return const [];
    }

    return rawProducts
        .whereType<Map>()
        .map((item) => StoreProduct.fromJson(Map<String, dynamic>.from(item)))
        .where((product) => product.id.isNotEmpty && product.title.isNotEmpty)
        .toList(growable: false);
  }

  Future<StoreProduct> retrieveProduct(String id) async {
    final regionId = await _regionRepository.getSaudiRegionId();
    final response = await _client.get(
      '/store/products/$id',
      queryParameters: {'region_id': regionId},
    );
    final rawProduct = response['product'];

    if (rawProduct is! Map) {
      throw const FormatException('Medusa product response is invalid.');
    }

    return StoreProduct.fromJson(Map<String, dynamic>.from(rawProduct));
  }
}
