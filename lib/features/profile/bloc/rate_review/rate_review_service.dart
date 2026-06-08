import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/network_service.dart';

import '../../model/rate_review_model.dart';

class RatingService {

  final NetworkService netWorkService = ServiceLocator.networkService;



  static Future<RatingsResponse> fetchProductRatings({
    required String productId,
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {

      String endpoint = 'products/$productId/ratings?page=$page&limit=$limit';

      if(status != null && status.isNotEmpty){
        endpoint += '&status=$status';
      }

      final Response response = await ServiceLocator.networkService.get(endpoint);

      if(response.statusCode == null){
        throw Exception('Somethng went wrong. Please try again later');
      }

      if(response.statusCode! >= 200 && response.statusCode! < 300){
        return RatingsResponse.fromJson(jsonDecode(response.data));
      }
      else {
        throw Exception(response.data['response'] ?? 'Failed to fetch orders');
      }
    } on DioException catch (e) {
      debugPrint('❌ Orders fetch error: ${e.message}');

      if (e.response?.statusCode == 400) {
        throw Exception('Invalid request data');
      } else if (e.response?.statusCode == 404) {
        // Return empty response instead of throwing error
        return RatingsResponse(
          status: true,
          response: 'No orders found',
          data:RatingsData(
            ratings: [],
            pagination:PaginationInfo (
              page: page,
              limit: limit,
              total: 0,
              totalPages: 0,
              hasNext: false,
              hasPrev: false,
            ),
          ),
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please try again.');
      } else {
        throw Exception('Somethng went wrong. Please try again later');
      }
    } catch (e) {
      debugPrint('❌ Error fetching orders: $e');
      if (e is Exception) rethrow;
      throw Exception('Something went wrong. Please try again.');
    }    
      
  }

  static Future<SubmitRatingResponse> submitProductRatings({
    required String productId,
    required double rating,
    required String review,
    required String status,
  }) async {
    try {

      final String productIdRating = 'products/$productId/ratings';
    
    //  if(status.isEmpty){
    //    throw Exception ('status is required');
    //  }

     final Map<String,dynamic> requestBody = {
         'rating': rating,
         'review': review,    
          'status': status,
     };
     debugPrint('Submitting rating: $requestBody to $productIdRating');

     final Response response = await ServiceLocator.networkService.post(
      productIdRating,
      data: requestBody,
     );

     if(response.statusCode == null){
      throw Exception('Somethng went wrong. Please try again later');
     }

     if(response.statusCode! > 200 && response.statusCode! < 300){
      return SubmitRatingResponse.fromJson(jsonDecode(response.data));
     }
     else {
      throw Exception(response.data['response'] ?? 'Failed to submit rating');
     }
    }
   catch (e) {
      debugPrint('❌ Error fetching orders: $e');
      if (e is Exception) rethrow;
      throw Exception('Something went wrong. Please try again.');
    }}
}