class DeliveryTypesResponse {
  final DeliveryType fast;
  final DeliveryType scheduled;
  final DeliveryType pickup;

  DeliveryTypesResponse({
    required this.fast,
    required this.scheduled,
    required this.pickup,
  });

  factory DeliveryTypesResponse.fromJson(Map<String, dynamic> json) {
    final types = json['data']['deliveryTypes'];
    return DeliveryTypesResponse(
      fast: DeliveryType.fromJson(types['fast']),
      scheduled: DeliveryType.fromJson(types['scheduled']),
      pickup: DeliveryType.fromJson(types['pickup']),
    );
  }
}

class DeliveryType {
  final bool available;
  final int charge;
  final String label;
  final String description;

  DeliveryType({
    required this.available,
    required this.charge,
    required this.label,
    required this.description,
  });

  factory DeliveryType.fromJson(Map<String, dynamic> json) {
    return DeliveryType(
      available: json['available'],
      charge: json['charge'],
      label: json['label'],
      description: json['description'],
    );
  }
}
