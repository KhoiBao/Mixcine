/// Enum định nghĩa các gói cước (pricing plans)
enum PaymentPlan {
  free('FREE', 'Thường', 0, 'Standard'),
  vip('VIP', 'Vip', 49000, 'Premium'),
  vipPro('VIP_PRO', 'Vippro', 99000, 'Ultra');

  const PaymentPlan(this.id, this.displayName, this.priceVnd, this.englishName);

  /// ID duy nhất cho gói
  final String id;

  /// Tên hiển thị (Tiếng Việt)
  final String displayName;

  /// Giá bán hàng tháng (VND)
  final int priceVnd;

  /// Tên tiếng Anh
  final String englishName;

  /// Mô tả nhanh về gói
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

  /// Độ phân giải tối đa được phép
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

  /// Số thiết bị được phép đồng thời
  int get maxDevices {
    switch (this) {
      case PaymentPlan.free:
        return 1;
      case PaymentPlan.vip:
        return 2;
      case PaymentPlan.vipPro:
        return 4;
    }
  }

  /// Có thể tải offline không
  bool get allowOfflineDownload {
    switch (this) {
      case PaymentPlan.free:
        return false;
      case PaymentPlan.vip:
        return true;
      case PaymentPlan.vipPro:
        return true;
    }
  }

  /// Có quảng cáo không
  bool get hasAds {
    switch (this) {
      case PaymentPlan.free:
        return true;
      case PaymentPlan.vip:
        return true;
      case PaymentPlan.vipPro:
        return false;
    }
  }

  /// Tìm gói theo ID
  static PaymentPlan fromId(String id) {
    return PaymentPlan.values.firstWhere(
      (plan) => plan.id == id,
      orElse: () => PaymentPlan.free,
    );
  }

  /// Format giá theo kiểu "49.000 đ"
  String get formattedPrice {
    if (priceVnd == 0) return 'Miễn phí';
    return '${(priceVnd / 1000).toStringAsFixed(0)}.000 đ';
  }
}
