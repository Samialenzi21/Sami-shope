import 'package:shop/core/network/medusa_client.dart';
import 'package:shop/features/checkout/data/models/store_order.dart';

class CheckoutRepository {
  CheckoutRepository({MedusaClient? client}) : _client = client ?? MedusaClient();

  final MedusaClient _client;

  Future<StoreOrder> placePickupOrder({
    required String cartId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    final pickupAddress = {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'address_1': 'Store Pickup',
      'city': 'Riyadh',
      'country_code': 'sa',
    };

    await _client.post(
      '/store/carts/$cartId',
      body: {
        'email': email,
        'shipping_address': pickupAddress,
        'billing_address': pickupAddress,
      },
    );

    final pickupOptionId = await _resolvePickupOptionId(cartId);

    await _client.post(
      '/store/carts/$cartId/shipping-methods',
      body: {'option_id': pickupOptionId},
    );

    final collectionResponse = await _client.post(
      '/store/payment-collections',
      body: {'cart_id': cartId},
    );
    final rawCollection = collectionResponse['payment_collection'];
    if (rawCollection is! Map) {
      throw const FormatException('Medusa payment collection response is invalid.');
    }

    final collectionId = rawCollection['id']?.toString();
    if (collectionId == null || collectionId.isEmpty) {
      throw const FormatException('Medusa payment collection has no ID.');
    }

    await _client.post(
      '/store/payment-collections/$collectionId/payment-sessions',
      body: {'provider_id': 'pp_system_default'},
    );

    final completion = await _client.post(
      '/store/carts/$cartId/complete',
      body: const {},
    );

    if (completion['type'] != 'order') {
      final error = completion['error'];
      if (error is Map && error['message'] != null) {
        throw StateError(error['message'].toString());
      }
      throw StateError('Medusa did not complete the cart into an order.');
    }

    final rawOrder = completion['order'];
    if (rawOrder is! Map) {
      throw const FormatException('Medusa order response is invalid.');
    }

    final order = StoreOrder.fromJson(Map<String, dynamic>.from(rawOrder));
    if (order.id.isEmpty) {
      throw const FormatException('Medusa completed an order without an ID.');
    }

    return order;
  }

  Future<String> _resolvePickupOptionId(String cartId) async {
    final response = await _client.get(
      '/store/shipping-options',
      queryParameters: {'cart_id': cartId},
    );

    final rawOptions = response['shipping_options'];
    if (rawOptions is! List) {
      throw const FormatException('Medusa shipping options response is invalid.');
    }

    for (final rawOption in rawOptions.whereType<Map>()) {
      final option = Map<String, dynamic>.from(rawOption);
      final type = option['type'];
      final code = type is Map ? type['code']?.toString() : null;
      final name = option['name']?.toString();

      if (code == 'pickup' || name == 'Store Pickup') {
        final id = option['id']?.toString();
        if (id != null && id.isNotEmpty) {
          return id;
        }
      }
    }

    throw StateError('Store Pickup shipping option is not available for this cart.');
  }
}
