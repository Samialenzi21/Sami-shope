class StoreProduct {
  const StoreProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    this.subtitle,
    this.thumbnail,
    this.variantId,
    this.price,
    this.currencyCode,
  });

  final String id;
  final String title;
  final String description;
  final String? subtitle;
  final String? thumbnail;
  final List<String> images;
  final String? variantId;
  final double? price;
  final String? currencyCode;

  bool get isPurchasable => variantId != null && price != null;

  factory StoreProduct.fromJson(Map<String, dynamic> json) {
    final variants = json['variants'] is List ? json['variants'] as List : const [];
    final firstVariant = variants.isNotEmpty && variants.first is Map
        ? Map<String, dynamic>.from(variants.first as Map)
        : null;

    final calculatedPrice = firstVariant?['calculated_price'] is Map
        ? Map<String, dynamic>.from(firstVariant!['calculated_price'] as Map)
        : null;

    final rawAmount = calculatedPrice?['calculated_amount'];
    final price = rawAmount is num ? rawAmount.toDouble() : null;

    final rawImages = json['images'] is List ? json['images'] as List : const [];
    final images = rawImages
        .whereType<Map>()
        .map((image) => image['url']?.toString())
        .whereType<String>()
        .where((url) => url.isNotEmpty)
        .toList(growable: true);

    final thumbnail = json['thumbnail']?.toString();
    if (thumbnail != null &&
        thumbnail.isNotEmpty &&
        !images.contains(thumbnail)) {
      images.insert(0, thumbnail);
    }

    return StoreProduct(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      description: json['description']?.toString() ?? '',
      thumbnail: thumbnail,
      images: List.unmodifiable(images),
      variantId: firstVariant?['id']?.toString(),
      price: price,
      currencyCode: calculatedPrice?['currency_code']?.toString(),
    );
  }
}
