import 'package:shop/core/network/medusa_api_exception.dart';
import 'package:shop/core/network/medusa_client.dart';
import 'package:shop/features/cart/data/models/store_cart.dart';
import 'package:shop/features/catalog/data/models/store_product.dart';
import 'package:shop/features/commerce/data/region_repository.dart';

class CartRepository {
  CartRepository({
    MedusaClient? client,
    RegionRepository? regionRepository,
  })  : _client = client ?? MedusaClient(),
        _regionRepository = regionRepository ?? RegionRepository(client: client);

  final MedusaClient _client;
  final RegionRepository _regionRepository;

  String? _cartId;

  Future<StoreCart?> retrieveCurrentCart() async {
    final cartId = _cartId;
    if (cartId == null) {
      return null;
    }

    try {
      final response = await _client.get('/store/carts/$cartId');
      return _cartFromResponse(response);
    } on MedusaApiException catch (error) {
      if (error.statusCode == 404) {
        _cartId = null;
        return null;
      }
      rethrow;
    }
  }

  Future<StoreCart> addProduct(
    StoreProduct product, {
    int quantity = 1,
  }) async {
    final variantId = product.variantId;
    if (variantId == null || variantId.isEmpty) {
      throw StateError('This product does not have a purchasable variant.');
    }

    final cart = await _ensureCart();
    final response = await _client.post(
      '/store/carts/${cart.id}/line-items',
      body: {
        'variant_id': variantId,
        'quantity': quantity,
      },
    );

    return _cartFromResponse(response);
  }

  Future<StoreCart> updateQuantity(
    StoreCartItem item,
    int quantity,
  ) async {
    final cartId = _requireCartId();
    if (quantity < 1) {
      return removeItem(item);
    }

    final response = await _client.post(
      '/store/carts/$cartId/line-items/${item.id}',
      body: {'quantity': quantity},
    );

    return _cartFromResponse(response);
  }

  Future<StoreCart> removeItem(StoreCartItem item) async {
    final cartId = _requireCartId();
    final response = await _client.delete(
      '/store/carts/$cartId/line-items/${item.id}',
    );

    final parent = response['parent'];
    if (parent is! Map) {
      throw const FormatException('Medusa delete line-item response is invalid.');
    }

    return StoreCart.fromJson(Map<String, dynamic>.from(parent));
  }

  void clearSession() {
    _cartId = null;
  }

  Future<StoreCart> _ensureCart() async {
    final current = await retrieveCurrentCart();
    if (current != null) {
      return current;
    }

    final regionId = await _regionRepository.getSaudiRegionId();
    final response = await _client.post(
      '/store/carts',
      body: {'region_id': regionId},
    );

    final cart = _cartFromResponse(response);
    if (cart.id.isEmpty) {
      throw const FormatException('Medusa created a cart without an ID.');
    }

    _cartId = cart.id;
    return cart;
  }

  String _requireCartId() {
    final cartId = _cartId;
    if (cartId == null || cartId.isEmpty) {
      throw StateError('No active Medusa cart exists.');
    }
    return cartId;
  }

  StoreCart _cartFromResponse(Map<String, dynamic> response) {
    final rawCart = response['cart'];
    if (rawCart is! Map) {
      throw const FormatException('Medusa cart response is invalid.');
    }

    final cart = StoreCart.fromJson(Map<String, dynamic>.from(rawCart));
    if (cart.id.isNotEmpty) {
      _cartId = cart.id;
    }
    return cart;
  }
}
