import 'package:shop/core/network/medusa_client.dart';
import 'package:shop/features/catalog/data/models/store_product.dart';

class ProductRepository {
  ProductRepository({MedusaClient? client}) : _client = client ?? MedusaClient();

  final MedusaClient _client;

  Future<List<StoreProduct>> listProducts({int limit = 20}) async {
    final response = await _client.get(
      '/store/products',
      queryParameters: {'limit': '$limit'},
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
    final response = await _client.get('/store/products/$id');
    final rawProduct = response['product'];

    if (rawProduct is! Map) {
      throw const FormatException('Medusa product response is invalid.');
    }

    return StoreProduct.fromJson(Map<String, dynamic>.from(rawProduct));
  }
}
