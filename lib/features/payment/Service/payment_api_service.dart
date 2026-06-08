import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/endpoints.dart';
import 'package:villag_kart/core/network/network_service.dart';

class PaymentApiService {
  final NetworkService _networkService = ServiceLocator.networkService;

  // ---------------- COD PAYMENT ----------------
  Future<void> createCODPayment(String orderId) async {
    final response = await _networkService.post(
      Endpoints.initiatePayment,
      data: {
        'orderId': orderId,
        'method': 'COD',
      },
    );

    if (response.data['status'] != true) {
      throw Exception(response.data['response']);
    }
  }

  // ---------------- RAZORPAY INIT ----------------
  Future<Map<String, dynamic>> initiateRazorpayPayment(String orderId) async {
  final response = await _networkService.post(
    Endpoints.initiatePayment,
    data: {
      'orderId': orderId,
      'method': 'RAZORPAY_UPI',
    },
  );

  if (response.data['status'] != true) {
    throw Exception(response.data['response']);
  }

  final data = response.data['data'];

  return {
    "orderId": data['payment']['orderId'],
    "razorpayOrderId": data['razorpay']['orderId'],
    "amount": (data['payment']['amount'] as num).toDouble(),
    "key": data['razorpay']['key'],
  };
}

Future<void> verifyPayment({
  required String orderId,
  required String razorpayPaymentId,
  required String razorpayOrderId,
  required String razorpaySignature,
}) async {
  final response = await _networkService.post(
     Endpoints.verifyPayment,
    data: {
      "orderId": orderId,
      "razorpayOrderId": razorpayOrderId,
      "razorpayPaymentId": razorpayPaymentId,
      "razorpaySignature": razorpaySignature,
    },
  );

  if (response.data['status'] != true) {
    throw Exception(response.data['response']);
  }
}
}
