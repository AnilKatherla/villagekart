import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/features/home/bloc/banner_bloc/banner_events.dart';
import 'package:villag_kart/features/home/bloc/banner_bloc/banner_service.dart';

import 'banner_state.dart';


class BannerBloc extends Bloc<BannerEvent, BannerState> {
  BannerBloc() : super(BannerInitial()) {
    on<FetchBannersEvent>(_onFetchBanners);
    on<RefreshBannersEvent>(_onRefreshBanners);
  }

  Future<void> _onFetchBanners(
    FetchBannersEvent event,
    Emitter<BannerState> emit,
  ) async {
    try {
      emit(BannerLoading());

      // ✅ THIS IS WHERE YOUR LINE GOES
      final banners = await BannerService.fetchBanners();

      emit(BannerSuccess(banners));
    } catch (e) {
      emit(BannerFailure(e.toString()));
    }
  }
  Future<void> _onRefreshBanners(
    RefreshBannersEvent event,
    Emitter<BannerState> emit,
  ) async {
    try {
      // 🔹 Keep old data if available (better UX)
      if (state is BannerSuccess) {
        emit(BannerRefreshing(
          (state as BannerSuccess).banners,
        ));
      } else {
        emit(BannerLoading());
      }

      final banners = await BannerService.fetchBanners();

      emit(BannerSuccess(banners));
    } catch (e) {
      emit(BannerFailure(e.toString()));
    }
  }
}
