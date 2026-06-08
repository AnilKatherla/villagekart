import 'package:villag_kart/features/home/model/banner_model.dart';



abstract class BannerState {}

class BannerInitial extends BannerState {}

class BannerLoading extends BannerState {}

class BannerSuccess extends BannerState {
  final List<BannerModel> banners;
  BannerSuccess(this.banners);
}
class BannerRefreshing extends BannerState {
  final List<BannerModel> banners;
  BannerRefreshing(this.banners);
}
class BannerEmpty extends BannerState {
  final String message;

  BannerEmpty({required this.message});
}
class BannerFailure extends BannerState {
  final String error;
  BannerFailure(this.error);
}
