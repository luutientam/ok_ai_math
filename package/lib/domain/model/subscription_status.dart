class SubscriptionStatus {
  final bool isActive;
  final String? activeProductId;
  final DateTime? expiryDate;
  final bool hasLifetime;
  final String message;

  SubscriptionStatus({
    required this.isActive,
    this.activeProductId,
    this.expiryDate,
    this.hasLifetime = false,
    this.message = '',
  });

  factory SubscriptionStatus.active({
    required String productId,
    DateTime? expiryDate,
    bool hasLifetime = false,
  }) {
    return SubscriptionStatus(
      isActive: true,
      activeProductId: productId,
      expiryDate: expiryDate,
      hasLifetime: hasLifetime,
      message: hasLifetime ? 'Lifetime subscription active' : 'Subscription active',
    );
  }

  factory SubscriptionStatus.expired({String? productId}) {
    return SubscriptionStatus(
      isActive: false,
      activeProductId: productId,
      message: 'Subscription expired',
    );
  }

  factory SubscriptionStatus.error(String errorMessage) {
    return SubscriptionStatus(isActive: false, message: errorMessage);
  }

  Map<String, dynamic> toJson() {
    return {
      'isActive': isActive,
      'activeProductId': activeProductId,
      'expiryDate': expiryDate?.toIso8601String(),
      'hasLifetime': hasLifetime,
      'message': message,
    };
  }
}
