class CouponModel {
  final String id;
  final String code;
  final String title;
  final String? description;
  final String type; // FLAT or PERCENT
  final int value; // discount value
  final int? maxDiscount;
  final int minOrderValue;
  final DateTime startDate;
  final DateTime expiryDate;
  final int? totalRemainingUses;

  CouponModel({
    required this.id,
    required this.code,
    required this.title,
    this.description,
    required this.type,
    required this.value,
    this.maxDiscount,
    required this.minOrderValue,
    required this.startDate,
    required this.expiryDate,
    this.totalRemainingUses,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'],
      code: json['code'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      value: json['value'],
      maxDiscount: json['maxDiscount'],
      minOrderValue: json['minOrderValue'],
      startDate: DateTime.parse(json['startDate']),
      expiryDate: DateTime.parse(json['expiryDate']),
      totalRemainingUses: json['totalRemainingUses'],
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiryDate);
}
