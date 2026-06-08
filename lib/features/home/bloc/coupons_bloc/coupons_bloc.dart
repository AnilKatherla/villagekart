// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:villag_kart/features/home/bloc/coupons_bloc/coupons_events.dart';
// import 'package:villag_kart/features/home/bloc/coupons_bloc/coupons_service.dart';
// import 'coupons_state.dart';

// class CouponsBloc extends Bloc<CouponsEvent, CouponsState> {
//   CouponsBloc() : super(CouponsInitial()) {
//     on<FetchCoupons>(_onFetchCoupons);
//     on<RefreshCoupons>(_onRefreshCoupons);
//   }

//   Future<void> _onFetchCoupons(
//     FetchCoupons event,
//     Emitter<CouponsState> emit,
//   ) async {
//     emit(CouponsLoading());

//     try {
//       final couponsResponse = await CouponsService.fetchCoupons(
//         userId: event.userId,
//         pincode: event.pincode,
//         cartValue: event.cartValue,
//       );

//       if (couponsResponse.data.count > 0) {
//         emit(CouponsLoaded(
//           coupons: couponsResponse.data.allCoupons,
//           personalizedCoupons: couponsResponse.data.personalized,
//           globalCoupons: couponsResponse.data.global,
//           totalCount: couponsResponse.data.count,
//         ));
//       } else {
//         emit(CouponsEmpty(
//           message: couponsResponse.message,
//         ));
//       }
//     } catch (e) {
//       emit(CouponsError(
//         errorMessage: e.toString().replaceAll('Exception: ', ''),
//       ));
//     }
//   }

//   Future<void> _onRefreshCoupons(
//     RefreshCoupons event,
//     Emitter<CouponsState> emit,
//   ) async {
//     if (state is CouponsLoaded) {
//       final currentState = state as CouponsLoaded;
//       emit(CouponsRefreshing(
//         coupons: currentState.coupons,
//         personalizedCoupons: currentState.personalizedCoupons,
//         globalCoupons: currentState.globalCoupons,
//         totalCount: currentState.totalCount,
//       ));

//       try {
//         final couponsResponse = await CouponsService.fetchCoupons(
//           userId: event.userId,
//           pincode: event.pincode,
//           cartValue: event.cartValue,
//         );

//         if (couponsResponse.data.count > 0) {
//           emit(CouponsLoaded(
//             coupons: couponsResponse.data.allCoupons,
//             personalizedCoupons: couponsResponse.data.personalized,
//             globalCoupons: couponsResponse.data.global,
//             totalCount: couponsResponse.data.count,
//           ));
//         } else {
//           emit(CouponsEmpty(
//             message: couponsResponse.message,
//           ));
//         }
//       } catch (e) {
//         emit(CouponsError(
//           errorMessage: e.toString().replaceAll('Exception: ', ''),
//         ));
//       }
//     }
//   }
// }

// coupons_bloc.dart
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/features/home/bloc/coupons_bloc/coupons_events.dart';
import 'package:villag_kart/features/home/bloc/coupons_bloc/coupons_service.dart';
import 'coupons_state.dart';

class CouponsBloc extends Bloc<CouponsEvent, CouponsState> {
  CouponsBloc() : super(CouponsInitial()) {
  on<FetchCoupons>(
    _onFetchCoupons,
    transformer: droppable(),
  );

  on<RefreshCoupons>(_onRefreshCoupons);
}


  Future<void> _onFetchCoupons(
    FetchCoupons event,
    Emitter<CouponsState> emit,
  ) async {
  
  if (state is CouponsLoading) return;


  if (state is CouponsLoaded) return;
    emit(CouponsLoading());

    try {
      final couponsResponse = await CouponsService.fetchCoupons(
     //   userId: event.userId,
        pincode: event.pincode,
        cartValue: event.cartValue,
      );

      final allCoupons = couponsResponse.data.allCoupons;
      
      if (allCoupons.isNotEmpty) {
        emit(CouponsLoaded(
          coupons: allCoupons,
          personalizedCoupons: couponsResponse.data.personalized,
          globalCoupons: couponsResponse.data.global,
          totalCount: couponsResponse.data.count,
        ));
      } else {
        emit(CouponsEmpty(
          message: couponsResponse.message,
        ));
      }
    } catch (e) {
      emit(CouponsError(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onRefreshCoupons(
    RefreshCoupons event,
    Emitter<CouponsState> emit,
  ) async {
    if (state is CouponsLoaded) {
      final currentState = state as CouponsLoaded;
      emit(CouponsRefreshing(
        coupons: currentState.coupons,
        personalizedCoupons: currentState.personalizedCoupons,
        globalCoupons: currentState.globalCoupons,
        totalCount: currentState.totalCount,
      ));

      try {
        final couponsResponse = await CouponsService.fetchCoupons(
       //   userId: event.userId,
          pincode: event.pincode,
          cartValue: event.cartValue,
        );

        final allCoupons = couponsResponse.data.allCoupons;
        
        if (allCoupons.isNotEmpty) {
          emit(CouponsLoaded(
            coupons: allCoupons,
            personalizedCoupons: couponsResponse.data.personalized,
            globalCoupons: couponsResponse.data.global,
            totalCount: couponsResponse.data.count,
          ));
        } else {
          emit(CouponsEmpty(
            message: couponsResponse.message,
          ));
        }
      } catch (e) {
        emit(CouponsError(
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ));
      }
    }
  }
}