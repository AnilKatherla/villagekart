import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/features/home/bloc/category_bloc/category_event.dart';
import 'package:villag_kart/features/home/bloc/category_bloc/category_state.dart';
import 'package:villag_kart/features/home/bloc/category_bloc/category_service.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc() : super(CategoryInitial()) {
    on<FetchCategories>(_onFetchCategories, transformer: droppable());
    on<RefreshCategories>(_onRefreshCategories);
  }

  Future<void> _onFetchCategories(
    FetchCategories event,
    Emitter<CategoryState> emit,
  ) async {
    // Guard: invalid location
    if (event.pincode.isEmpty) {
      debugPrint('⚠️ FetchCategories blocked — empty pincode');
      emit(CategoryError(errorMessage: 'Invalid location data'));
      return;
    }

    emit(CategoryLoading());

    try {
      final categoryResponse = await CategoryService.fetchCategories(
        pincode: event.pincode,
      );

      // Guard: null data
      if (categoryResponse.data == null) {
        debugPrint('⚠️ Category response data is null');
        emit(CategoryEmpty());
        return;
      }

      final data = categoryResponse.data!;

      // Guard: empty categories
      if (data.categories.isEmpty) {
        debugPrint('⚠️ No categories returned');
        emit(CategoryEmpty());
        return;
      }

      emit(CategoryLoaded(
        categories: data.categories,
        warehouse: data.warehouse,
        isServiceable: data.serviceable,
      ));
    } catch (e) {
      debugPrint('❌ CategoryBloc error: $e');
      emit(CategoryError(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onRefreshCategories(
    RefreshCategories event,
    Emitter<CategoryState> emit,
  ) async {
    if (state is! CategoryLoaded) return;

    final currentState = state as CategoryLoaded;

    // Guard: invalid location
    if (event.pincode.isEmpty) {
      debugPrint('⚠️ RefreshCategories blocked — empty pincode');
      return;
    }

    emit(CategoryRefreshing(
      categories: currentState.categories,
      warehouse: currentState.warehouse,
      isServiceable: currentState.isServiceable,
    ));

    try {
      final categoryResponse = await CategoryService.fetchCategories(
        pincode: event.pincode,
      );

      if (categoryResponse.data == null ||
          categoryResponse.data!.categories.isEmpty) {
        emit(CategoryEmpty());
        return;
      }

      final data = categoryResponse.data!;

      emit(CategoryLoaded(
        categories: data.categories,
        warehouse: data.warehouse,
        isServiceable: data.serviceable,
      ));
    } catch (e) {
      debugPrint('❌ CategoryBloc refresh error: $e');
      // On refresh failure, restore previous loaded state
      emit(CategoryLoaded(
        categories: currentState.categories,
        warehouse: currentState.warehouse,
        isServiceable: currentState.isServiceable,
      ));
    }
  }
}