import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shop/core/network/medusa_client.dart';
import 'package:shop/features/cart/data/cart_repository.dart';
import 'package:shop/features/catalog/data/models/store_product.dart';
import 'package:shop/features/commerce/data/region_repository.dart';

void main() {
  test('creates a Saudi cart and adds a Medusa variant', () async {
    final calls = <String>[];

    final httpClient = MockClient((request) async {
      calls.add('${request.method} ${request.url.path}');

      if (request.method == 'GET' && request.url.path == '/store/regions') {
        return http.Response(
          jsonEncode({
            'regions': [
              {
                'id': 'reg_sa',
                'name': 'Saudi Arabia',
                'currency_code': 'sar',
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      if (request.method == 'POST' && request.url.path == '/store/carts') {
        expect(jsonDecode(request.body), {'region_id': 'reg_sa'});
        return http.Response(
          jsonEncode({
            'cart': {
              'id': 'cart_1',
              'currency_code': 'sar',
              'region_id': 'reg_sa',
              'items': [],
              'subtotal': 0,
              'total': 0,
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      if (request.method == 'POST' &&
          request.url.path == '/store/carts/cart_1/line-items') {
        expect(jsonDecode(request.body), {
          'variant_id': 'variant_spanish_latte',
          'quantity': 1,
        });
        return http.Response(
          jsonEncode({
            'cart': {
              'id': 'cart_1',
              'currency_code': 'sar',
              'region_id': 'reg_sa',
              'subtotal': 18,
              'total': 18,
              'items': [
                {
                  'id': 'item_1',
                  'product_title': 'Spanish Latte',
                  'variant_id': 'variant_spanish_latte',
                  'quantity': 1,
                  'unit_price': 18,
                },
              ],
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      return http.Response('Not found', 404);
    });

    final medusa = MedusaClient(
      baseUrl: 'https://api.example.com',
      publishableKey: 'pk_test',
      httpClient: httpClient,
    );
    final regions = RegionRepository(client: medusa);
    final repository = CartRepository(
      client: medusa,
      regionRepository: regions,
    );

    const product = StoreProduct(
      id: 'prod_1',
      title: 'Spanish Latte',
      description: '',
      images: [],
      variantId: 'variant_spanish_latte',
      price: 18,
      currencyCode: 'sar',
    );

    final cart = await repository.addProduct(product);

    expect(cart.id, 'cart_1');
    expect(cart.currencyCode, 'sar');
    expect(cart.quantity, 1);
    expect(cart.total, 18);
    expect(cart.items.single.title, 'Spanish Latte');
    expect(calls, [
      'GET /store/regions',
      'POST /store/carts',
      'POST /store/carts/cart_1/line-items',
    ]);
  });
}
