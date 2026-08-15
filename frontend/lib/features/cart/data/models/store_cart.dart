class StoreCart {
  const StoreCart({
    required this.id,
    required this.currencyCode,
    required this.regionId,
    required this.items,
    required this.subtotal,
    required this.total,
  });

  final String id;
  final String currencyCode;
  final String? regionId;
  final List<StoreCartItem> items;
  final double subtotal;
  final double total;

  int get quantity => items.fold(0, (sum, item) => sum + item.quantity);

  factory StoreCart.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] is List ? json['items'] as List : const [];

    return StoreCart(
      id: json['id']?.toString() ?? '',
      currencyCode: json['currency_code']?.toString() ?? 'sar',
      regionId: json['region_id']?.toString(),
      items: rawItems
          .whereType<Map>()
          .map((item) => StoreCartItem.fromJson(Map<String, dynamic>.from(item)))
          .where((item) => item.id.isNotEmpty)
          .toList(growable: false),
      subtotal: _number(json['subtotal']),
      total: _number(json['total']),
    );
  }

  static double _number(dynamic value) => value is num ? value.toDouble() : 0;
}

class StoreCartItem {
  const StoreCartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.unitPrice,
    this.variantId,
    this.thumbnail,
  });

  final String id;
  final String title;
  final String? variantId;
  final String? thumbnail;
  final int quantity;
  final double unitPrice;

  double get lineTotal => unitPrice * quantity;

  factory StoreCartItem.fromJson(Map<String, dynamic> json) {
    final rawQuantity = json['quantity'];
    final rawUnitPrice = json['unit_price'];

    return StoreCartItem(
      id: json['id']?.toString() ?? '',
      title: json['product_title']?.toString() ??
          json['title']?.toString() ??
          'Product',
      variantId: json['variant_id']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
      quantity: rawQuantity is num ? rawQuantity.toInt() : 0,
      unitPrice: rawUnitPrice is num ? rawUnitPrice.toDouble() : 0,
    );
  }
}
