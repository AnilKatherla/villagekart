/**
 * **************************************************************
 * @author: Venkat Phanitapu
 * @date: 12 November 2025
 * @project: VillagKart
 * @description: [Widget or ViewModel description]
 * **************************************************************
 */
class AddressModel {
  final String label; // Home / Office / etc
  final String address;
  final String? type;
  final double latitude;    
  final double longitude;   

  AddressModel({
    required this.label,
    this.type,
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}
