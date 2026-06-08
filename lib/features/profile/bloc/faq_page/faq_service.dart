import 'package:dio/dio.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/endpoints.dart';
import 'package:villag_kart/core/network/network_service.dart';
import 'package:villag_kart/features/profile/model/faq_model.dart';


class DeliveryFaqApiService {
  final NetworkService _networkService = ServiceLocator.networkService;

  Future<List<DeliveryFaq>> fetchDeliveryFaqs() async {
    try {
      final response = await _networkService.get(
        Endpoints.deliveryFaq,
      );

      // HTTP validation
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch FAQs');
      }

      final data = response.data;

      // API validation
      if (data['status'] != true) {
        throw Exception(data['response'] ?? 'Failed to fetch FAQs');
      }

      // Parse response
      final result = DeliveryFaqResponse.fromJson(data);

      return result.data;
    } on DioException catch (e) {
      final message = e.response?.data?['response'] ?? e.message;
      throw Exception(message);
    }
  }
}