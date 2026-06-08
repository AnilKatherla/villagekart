// class DeliverySlotResponseModel {
//   final String pincode;
//   final String date;
//   final WarehouseModel warehouse;
//   final List<DeliverySlotModel> slots;
//   final String message;

//   DeliverySlotResponseModel({
//     required this.pincode,
//     required this.date,
//     required this.warehouse,
//     required this.slots,
//     required this.message,
//   });

//   factory DeliverySlotResponseModel.fromJson(Map<String, dynamic> json) {
//     return DeliverySlotResponseModel(
//       pincode: json['pincode'],
//       date: json['date'] ?? '',
//       warehouse: WarehouseModel.fromJson(json['warehouse'] ),
//       slots: (json['slots']as List)
//           .map((e) => DeliverySlotModel.fromJson(e))
//           .toList(),
//       message: json['message']?? '',
//     );
//   }
// }




// class WarehouseModel {
//   final String id;
//   final String name;
//   final String code;

//   WarehouseModel({
//     required this.id,
//     required this.name,
//     required this.code,
//   });

//   factory WarehouseModel.fromJson(Map<String, dynamic> json) {
//     return WarehouseModel(
//       id: json['id'],
//       name: json['name'],
//       code: json['code'],
//     );
//   }
// }

// class DeliverySlotModel {
//   final String id;
//   final String slot;
//   final String time;
//   final String startTime;
//   final String endTime;
//   final int available;
//   final int capacity;
//   final int booked;
//   final bool isAvailable;
//   final String slotId;
 

//   DeliverySlotModel({
//     required this.id,
//     required this.slot,
//     required this.time,
//     required this.startTime,
//     required this.endTime,
//     required this.available,
//     required this.capacity,
//     required this.booked,
//     required this.isAvailable,
//     required this.slotId
//   });

//   factory DeliverySlotModel.fromJson(Map<String, dynamic> json) {
//     return DeliverySlotModel(
//       id: json['id'] ?? '',
//       slot: json['slot'] ?? '',
//       time: json['time'] ?? '',
//       startTime: json['startTime'] ?? '',
//       endTime: json['endTime'] ?? '',
//       available: json['available'] ?? 0,
//       capacity: json['capacity'] ?? 0,
//       booked: json['booked'] ?? 0,
//       isAvailable: json['isAvailable'] ?? false,
//       slotId: json['slotId'] ?? '',
//     );

//   }
// }

class DeliverySlotResponseModel {
  final bool status;
  final String response;
  final DeliverySlotData data;

  DeliverySlotResponseModel({
    required this.status,
    required this.response,
    required this.data,
  });

  factory DeliverySlotResponseModel.fromJson(Map<String, dynamic> json) {
    return DeliverySlotResponseModel(
      status: json['status'] ?? false,
      response: json['response'] ?? '',
      data: DeliverySlotData.fromJson(
        json['data'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class DeliverySlotData {
  final List<DeliverySlotModel> slots;

  DeliverySlotData({required this.slots});

  factory DeliverySlotData.fromJson(Map<String, dynamic> json) {
    return DeliverySlotData(
      slots: (json['slots'] as List<dynamic>? ?? [])
          .map((e) =>
              DeliverySlotModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DeliverySlotModel {
  final String id;
  final String slot;
  final String time;
  final String startTime;
  final String endTime;
  final int available;
  final int capacity;
  final int booked;
  final bool isAvailable;
  final String slotId;

  DeliverySlotModel({
    required this.id,
    required this.slot,
    required this.time,
    required this.startTime,
    required this.endTime,
    required this.available,
    required this.capacity,
    required this.booked,
    required this.isAvailable,
    required this.slotId,
  });

  factory DeliverySlotModel.fromJson(Map<String, dynamic> json) {
    return DeliverySlotModel(
      id: json['id'] ?? '',
      slot: json['slot'] ?? '',
      time: json['time'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      available: json['available'] ?? 0,
      capacity: json['capacity'] ?? 0,
      booked: json['booked'] ?? 0,
      isAvailable: json['isAvailable'] ?? false,
      slotId: json['slotId'] ?? '',
    );
  }
}
