import 'package:flutter_test/flutter_test.dart';
import 'package:shop/features/catalog/data/models/store_product.dart';

void main() {
  test('StoreProduct parses Medusa product payload', () {
    final product = StoreProduct.fromJson({
      'id': 'prod_123',
      'title': 'Spanish Latte',
      'description': 'Cold coffee drink',
      'thumbnail': 'https://cdn.example.com/product.jpg',
      'images': [
        {'url': 'https://cdn.example.com/product.jpg'},
      ],
      'variants': [
        {
          'id': 'variant_123',
          'calculated_price': {
            'calculated_amount': 18,
            'currency_code': 'sar',
          },
        },
      ],
    });

    expect(product.id, 'prod_123');
    expect(product.title, 'Spanish Latte');
    expect(product.variantId, 'variant_123');
    expect(product.price, 18);
    expect(product.currencyCode, 'sar');
    expect(product.isPurchasable, isTrue);
  });
}
