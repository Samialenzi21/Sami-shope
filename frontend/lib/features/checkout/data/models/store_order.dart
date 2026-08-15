class StoreOrder {
  const StoreOrder({
    required this.id,
    required this.displayId,
    required this.currencyCode,
    required this.total,
  });

  final String id;
  final int? displayId;
  final String currencyCode;
  final double total;

  factory StoreOrder.fromJson(Map<String, dynamic> json) {
    final rawDisplayId = json['display_id'];
    final rawTotal = json['total'];

    return StoreOrder(
      id: json['id']?.toString() ?? '',
      displayId: rawDisplayId is num ? rawDisplayId.toInt() : null,
      currencyCode: json['currency_code']?.toString() ?? 'sar',
      total: rawTotal is num ? rawTotal.toDouble() : 0,
    );
  }
}
