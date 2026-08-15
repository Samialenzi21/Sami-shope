import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shop/core/network/medusa_client.dart';
import 'package:shop/features/checkout/data/checkout_repository.dart';

void main() {
  test('places a store-pickup COD order through Medusa', () async {
    final calls = <String>[];

    final httpClient = MockClient((request) async {
      calls.add('${request.method} ${request.url.path}');
      expect(request.headers['x-publishable-api-key'], 'pk_test');

      if (request.method == 'POST' &&
          request.url.path == '/store/carts/cart_1') {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['email'], 'customer@example.com');
        expect(body['shipping_address']['country_code'], 'sa');
        return _jsonResponse({
          'cart': {
            'id': 'cart_1',
            'currency_code': 'sar',
            'items': [],
            'subtotal': 20,
            'total': 20,
          },
        });
      }

      if (request.method == 'GET' &&
          request.url.path == '/store/shipping-options') {
        expect(request.url.queryParameters['cart_id'], 'cart_1');
        return _jsonResponse({
          'shipping_options': [
            {
              'id': 'so_pickup',
              'name': 'Store Pickup',
              'type': {'code': 'pickup'},
            },
          ],
        });
      }

      if (request.method == 'POST' &&
          request.url.path == '/store/carts/cart_1/shipping-methods') {
        expect(jsonDecode(request.body), {'option_id': 'so_pickup'});
        return _jsonResponse({
          'cart': {'id': 'cart_1'},
        });
      }

      if (request.method == 'POST' &&
          request.url.path == '/store/payment-collections') {
        expect(jsonDecode(request.body), {'cart_id': 'cart_1'});
        return _jsonResponse({
          'payment_collection': {'id': 'paycol_1'},
        });
      }

      if (request.method == 'POST' &&
          request.url.path ==
              '/store/payment-collections/paycol_1/payment-sessions') {
        expect(jsonDecode(request.body), {'provider_id': 'pp_system_default'});
        return _jsonResponse({
          'payment_collection': {'id': 'paycol_1'},
        });
      }

      if (request.method == 'POST' &&
          request.url.path == '/store/carts/cart_1/complete') {
        return _jsonResponse({
          'type': 'order',
          'order': {
            'id': 'order_1',
            'display_id': 42,
            'currency_code': 'sar',
            'total': 20,
          },
        });
      }

      return http.Response('Not found', 404);
    });

    final repository = CheckoutRepository(
      client: MedusaClient(
        baseUrl: 'https://api.example.com',
        publishableKey: 'pk_test',
        httpClient: httpClient,
      ),
    );

    final order = await repository.placePickupOrder(
      cartId: 'cart_1',
      firstName: 'Sami',
      lastName: 'Customer',
      email: 'customer@example.com',
      phone: '0500000000',
    );

    expect(order.id, 'order_1');
    expect(order.displayId, 42);
    expect(order.currencyCode, 'sar');
    expect(order.total, 20);
    expect(calls, [
      'POST /store/carts/cart_1',
      'GET /store/shipping-options',
      'POST /store/carts/cart_1/shipping-methods',
      'POST /store/payment-collections',
      'POST /store/payment-collections/paycol_1/payment-sessions',
      'POST /store/carts/cart_1/complete',
    ]);
  });
}

http.Response _jsonResponse(Map<String, dynamic> body) {
  return http.Response(
    jsonEncode(body),
    200,
    headers: {'content-type': 'application/json'},
  );
}
