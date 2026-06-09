enum PaymentPlan {
  free('FREE', 'Thường', 0, 'Standard'),
  vip('VIP', 'Vip', 49000, 'Premium'),
  vipPro('VIP_PRO', 'Vippro', 99000, 'Ultra');

  const PaymentPlan(this.id, this.displayName, this.priceVnd, this.englishName);

  final String id;
  final String displayName;
  final int priceVnd;
  final String englishName;

  String get description {
    switch (this) {
      case PaymentPlan.free:
        return 'Phim 480p, 1 thiết bị, có quảng cáo';
      case PaymentPlan.vip:
        return 'Phim HD 720p, 2 thiết bị, tải offline';
      case PaymentPlan.vipPro:
        return 'Phim 4K, 4 thiết bị, tải offline, không quảng cáo';
    }
  }

  String get maxResolution {
    switch (this) {
      case PaymentPlan.free:
        return '480p';
      case PaymentPlan.vip:
        return '720p';
      case PaymentPlan.vipPro:
        return '4K';
    }
  }

  bool get allowOfflineDownload => this != PaymentPlan.free;

  bool get hasAds => this == PaymentPlan.free || this == PaymentPlan.vip;

  static PaymentPlan fromId(String id) {
    return PaymentPlan.values.firstWhere(
      (plan) => plan.id.toUpperCase() == id.toUpperCase(),
      orElse: () => PaymentPlan.free,
    );
  }

  String get formattedPrice {
    if (priceVnd == 0) return 'Miễn phí';
    return '${(priceVnd / 1000).toStringAsFixed(0)}.000 đ';
  }
}
