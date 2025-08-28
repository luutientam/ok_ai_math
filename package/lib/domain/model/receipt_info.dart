class ReceiptInfo {
  final String productId;
  final int expiresDateMs;
  final String transactionId;
  final String originalTransactionId;
  final int purchaseDateMs;

  ReceiptInfo({
    required this.productId,
    required this.expiresDateMs,
    required this.transactionId,
    required this.originalTransactionId,
    required this.purchaseDateMs,
  });

  factory ReceiptInfo.fromJson(Map<String, dynamic> json) {
    return ReceiptInfo(
      productId: json['product_id'] as String? ?? '',
      expiresDateMs: int.tryParse(json['expires_date_ms'] as String? ?? '0') ?? 0,
      transactionId: json['transaction_id'] as String? ?? '',
      originalTransactionId: json['original_transaction_id'] as String? ?? '',
      purchaseDateMs: int.tryParse(json['purchase_date_ms'] as String? ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'expires_date_ms': expiresDateMs.toString(),
      'transaction_id': transactionId,
      'original_transaction_id': originalTransactionId,
      'purchase_date_ms': purchaseDateMs.toString(),
    };
  }
}
