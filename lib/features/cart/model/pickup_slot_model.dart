class PickupSlotResponse {
  final bool status;
  final String response;
  final Store store;
  final String date;
  final List<Slot> slots;


  PickupSlotResponse({
    required this.status,
    required this.response,
    required this.store,
    required this.date,
    required this.slots,
  });

  factory PickupSlotResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return PickupSlotResponse(
      status: json['status'],
      response: json['response'],
      store: Store.fromJson(data['store']),
      date: data['date'],
      slots: (data['slots'] as List)
          .map((e) => Slot.fromJson(e))
          .toList(),
    );
  }
}

class Store {
  final String id;
  final String name;
  final Location location;

  Store({required this.id, required this.name, required this.location,});

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      name: json['name'],
       location: Location.fromJson(json['location']),
    );
  }
}

class Location {
  final String city;
  final String line1;
  final String line2;
  final String state;
  final String colony;
  final String mandal;
  final String pincode;

  Location({
    required this.city,
    required this.line1,
    required this.line2,
    required this.state,
    required this.colony,
    required this.mandal,
    required this.pincode,
  });

  factory Location.fromJson(Map<String,dynamic>json){
    return Location(
      city: json['city'] ?? '', 
      line1: json['line1'] ?? '', 
      line2:  json['line2'] ?? '',
      state:  json['state'] ?? '',
      colony:  json['colony'] ?? '',
      mandal:  json['mandal'] ?? '',
      pincode:  json['pincode'] ?? ''
      );
  }
}

class Slot {
  final String time;
  final String startTime;
  final String endTime;
  final bool available;
  final int booked;
  final int capacity;

  Slot({
    required this.time,
    required this.startTime,
    required this.endTime,
    required this.available,
    required this.booked,
    required this.capacity,
  });

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      time: json['time'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      available: json['available'],
      booked: json['booked'],
      capacity: json['capacity'],
    );
  }
}
