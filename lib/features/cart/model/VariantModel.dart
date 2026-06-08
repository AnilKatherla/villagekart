class VariantModel {
  VariantModel({
    required this.id,
    required this.name,
    required this.unit,
    required this.measurement,
    required this.mrp,
    required this.price,
    required this.discount,
    required this.stock,
    required this.inStock,
    required this.minOrderQty,
    required this.maxOrderQty,
    required this.images,
  });

  factory VariantModel.fromJson(Map<String, dynamic> json) {
    return VariantModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      unit: json['unit'] ?? '',
      measurement: json['measurement'] ?? '',
      mrp: (json['mrp'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] ?? 0,
      inStock: json['inStock'] ?? false,
      minOrderQty: json['minOrderQty'] ?? 1,
      maxOrderQty: json['maxOrderQty'] is int ? json['maxOrderQty'] : 1,
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
  final String id;
  final String name;
  final String unit;
  final String measurement;
  final double mrp;
  final double price;
  final double discount;
  final int stock;
  final bool inStock;
  final int minOrderQty;
  final int maxOrderQty;
  final List<String> images;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'measurement': measurement,
      'mrp': mrp,
      'price': price,
      'discount': discount,
      'stock': stock,
      'inStock': inStock,
      'minOrderQty': minOrderQty,
      'maxOrderQty': maxOrderQty,
      'images': images,
    };
  }

  //to string method for logs
  @override
  String toString() {
    return 'VariantModel{id: $id, name: $name, unit: $unit, measurement: $measurement, mrp: $mrp, price: $price, discount: $discount, stock: $stock, inStock: $inStock, minOrderQty: $minOrderQty, maxOrderQty: $maxOrderQty, images: $images}';
  }
}
