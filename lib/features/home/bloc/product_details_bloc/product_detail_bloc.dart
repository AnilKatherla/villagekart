// features/product_detail/bloc/product_detail_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/features/home/bloc/product_details_bloc/product_detail_state.dart';
import 'product_detail_event.dart';
import 'product_detail_service.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  ProductDetailBloc() : super(ProductDetailInitial()) {
    on<FetchProductDetail>(_onFetchProductDetail);
    on<RefreshProductDetail>(_onRefreshProductDetail);
  }

  Future<void> _onFetchProductDetail(
    FetchProductDetail event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(ProductDetailLoading());

    try {
      final productDetailResponse =
          await ProductDetailService.fetchProductDetail(
            productId: event.productId,
            pincode: event.pincode,
          );

      emit(
        ProductDetailLoaded(
          product: productDetailResponse.data,
          warehouse: productDetailResponse.data.warehouse!,
          isServiceable: true, //TODO: handle serviceable logic
        ),
      );
    } catch (e) {
      emit(
        ProductDetailError(
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onRefreshProductDetail(
    RefreshProductDetail event,
    Emitter<ProductDetailState> emit,
  ) async {
    if (state is ProductDetailLoaded) {
      final currentState = state as ProductDetailLoaded;
      emit(
        ProductDetailRefreshing(
          product: currentState.product,
          warehouse: currentState.warehouse,
          isServiceable: currentState.isServiceable,
        ),
      );

      try {
        final productDetailResponse =
            await ProductDetailService.fetchProductDetail(
              productId: event.productId,
              pincode: event.pincode,
            );

        emit(
          ProductDetailLoaded(
            product: productDetailResponse.data,
            warehouse: productDetailResponse.data.warehouse!,
            isServiceable: true, //TODO: handle serviceable logic
          ),
        );
      } catch (e) {
        emit(
          ProductDetailError(
            errorMessage: e.toString().replaceAll('Exception: ', ''),
          ),
        );
      }
    }
  }
}
