import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:villag_kart/core/network/network_service.dart';

class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;

  static T locate<T extends Object>() => _getIt<T>();

  static Future<void> register() async {
    _getIt
      ..registerLazySingleton<Dio>(() => Dio())
      ..registerLazySingleton<NetworkService>(
        () => NetworkService(_getIt<Dio>()),
      );
  }

  static NetworkService get networkService => locate<NetworkService>();
}
