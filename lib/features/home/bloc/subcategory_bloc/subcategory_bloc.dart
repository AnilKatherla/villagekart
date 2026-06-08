// subcategory_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/features/home/bloc/subcategory_bloc/subcategory_service.dart';
import 'package:villag_kart/features/home/model/category_model.dart';
import 'package:villag_kart/features/home/model/product_response.dart';

// Events
abstract class SubCategoryEvent {}

class FetchSubCategories extends SubCategoryEvent {
  final String categoryId;
  final String pincode;

  FetchSubCategories({
    required this.categoryId,
    required this.pincode,
  });
}

class RefreshSubCategories extends SubCategoryEvent {
  final String categoryId;
  final String pincode;

  RefreshSubCategories({
    required this.categoryId,
    required this.pincode,
  });
}

// States
abstract class SubCategoryState {}

class SubCategoryInitial extends SubCategoryState {}

class SubCategoryLoading extends SubCategoryState {}

class SubCategoryLoaded extends SubCategoryState {
  final List<SubCategory> subcategories;
  final Warehouse warehouse;
  final bool isServiceable;
  final int count;

  SubCategoryLoaded({
    required this.subcategories,
    required this.warehouse,
    required this.isServiceable,
    required this.count,
  });
}

class SubCategoryError extends SubCategoryState {
  final String errorMessage;

  SubCategoryError({required this.errorMessage});
}

// BLoC
class SubCategoryBloc extends Bloc<SubCategoryEvent, SubCategoryState> {
  SubCategoryBloc() : super(SubCategoryInitial()) {
    on<FetchSubCategories>(_onFetchSubCategories);
    on<RefreshSubCategories>(_onRefreshSubCategories);
  }

  Future<void> _onFetchSubCategories(
    FetchSubCategories event,
    Emitter<SubCategoryState> emit,
  ) async {
    emit(SubCategoryLoading());

    try {
      final subCategoryResponse = await SubCategoryService.fetchSubCategories(
        categoryId: event.categoryId,
        pincode: event.pincode,
      );

      emit(SubCategoryLoaded(
        subcategories: subCategoryResponse.data.subcategories,
        warehouse: subCategoryResponse.data.warehouse,
        isServiceable: subCategoryResponse.data.serviceable,
        count: subCategoryResponse.data.count,
      ));
    } catch (e) {
      emit(SubCategoryError(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onRefreshSubCategories(
    RefreshSubCategories event,
    Emitter<SubCategoryState> emit,
  ) async {
    if (state is SubCategoryLoaded) {
      final currentState = state as SubCategoryLoaded;
      
      try {
        final subCategoryResponse = await SubCategoryService.fetchSubCategories(
          categoryId: event.categoryId,
          pincode: event.pincode,
        );

        emit(SubCategoryLoaded(
          subcategories: subCategoryResponse.data.subcategories,
          warehouse: subCategoryResponse.data.warehouse,
          isServiceable: subCategoryResponse.data.serviceable,
          count: subCategoryResponse.data.count,
        ));
      } catch (e) {
        emit(SubCategoryError(
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ));
      }
    }
  }
}