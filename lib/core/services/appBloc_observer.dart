import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/core/services/crashlytics_service.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    CrashlyticsService.recordError(error, stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}
