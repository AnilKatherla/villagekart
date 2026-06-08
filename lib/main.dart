library;

import 'dart:developer';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/navigation/app_router.dart';
import 'package:villag_kart/core/services/appBloc_observer.dart';
import 'package:villag_kart/core/services/crashlytics_service.dart';
import 'package:villag_kart/core/services/notification_service.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/core/utils/global_snackbar.dart';
import 'package:villag_kart/env_loader.dart';
import 'package:villag_kart/environmental_variables.dart';
import 'package:villag_kart/features/cart/bloc/cart_bloc.dart';
import 'package:villag_kart/features/cart/bloc/promocode_bloc/promocode_bloc.dart';
import 'package:villag_kart/features/home/bloc/banner_bloc/banner_bloc.dart';
import 'package:villag_kart/features/home/bloc/banner_bloc/banner_events.dart';
import 'package:villag_kart/features/home/bloc/brands_bloc/brands_bloc.dart';
import 'package:villag_kart/features/home/bloc/category_bloc/category_bloc.dart';
import 'package:villag_kart/features/home/bloc/coupons_bloc/coupons_bloc.dart';
import 'package:villag_kart/features/home/bloc/home_bloc/home_bloc.dart';
import 'package:villag_kart/features/home/bloc/offers_bloc/offers_bloc.dart';
import 'package:villag_kart/features/home/bloc/popular_products_bloc/popular_products_bloc.dart';
import 'package:villag_kart/features/home/bloc/suggestions/Product_suggestions_bloc.dart';
import 'package:villag_kart/features/location/bloc/location_bloc.dart';
import 'package:villag_kart/features/onboard/bloc/login_bloc.dart';
import 'package:villag_kart/features/order_status/order_status_cubit.dart';
import 'package:villag_kart/features/payment/Service/payment_api_service.dart';
import 'package:villag_kart/features/payment/bloc/payment_bloc.dart';
import 'package:villag_kart/features/profile/bloc/manage_address/manage_address_bloc.dart';
import 'package:villag_kart/features/profile/bloc/manage_address/manage_address_event.dart';
import 'package:villag_kart/features/profile/bloc/order_status/order_status_bloc.dart';
import 'package:villag_kart/features/register/bloc/register_bloc.dart';
import 'package:villag_kart/features/wishlist/bloc/wishlist_bloc.dart';
import 'package:villag_kart/features/wishlist/bloc/wishlist_event.dart';
import 'package:villag_kart/firebase_options_parser.dart';
import 'package:villag_kart/maintenance_screen.dart';
import 'package:force_update_helper/force_update_helper.dart';
import 'package:villag_kart/core/services/force_update_service.dart';

import 'features/profile/bloc/edit_profile/edit_profile_bloc.dart';
import 'features/profile/bloc/order_history_bloc.dart';
import 'package:villag_kart/core/realtime/realtime_app_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Loading env files
  try {
    await EnvLoader.loadEnv();

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: FirebaseOptionsParser.options);
      }
    } catch (e) {
      // If already initialized → ignore safely
      debugPrint("Firebase already initialized: $e");
    }

    // ALWAYS safe
    await CrashlyticsService.init();

    Bloc.observer = AppBlocObserver();

    // global handlers
    FlutterError.onError = (details) {
      FirebaseCrashlytics.instance.recordFlutterError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    log('Error loading env files: $e');
    if (e is EnvFileNotFoundException) {
      runApp(
        MaterialApp(
          builder: (context, child) {
            final MediaQueryData data = MediaQuery.of(context);
            final scale = data.textScaler.scale(1.0).clamp(0.99, 1.01);
            return MediaQuery(
              data: data.copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            );
          },
          home: const MaintenanceScreen(),
        ),
      );
    } else {
      rethrow;
    }
  }

  // ✅ Initialize Notification Service
  await NotificationService().initialize();

  // ✅ Get FCM Token safely
  try {
    final token = await NotificationService().getToken();
    log('FCM Token: $token');
  } catch (e) {
    log('Error fetching FCM token: $e');
  }

  // ✅ Register GetIt services BEFORE runApp
  await ServiceLocator.register();

  final storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );

  HydratedBloc.storage = storage;

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiBlocProvider(
      providers: [
        //Global bloc instances
        BlocProvider<CartBloc>(create: (_) => CartBloc()), //Singleton instance
        BlocProvider(create: (_) => PromoCodeBloc()),

        BlocProvider<AddressBloc>(
          create: (_) => AddressBloc()..add(FetchAddresses()),
        ),

        BlocProvider<HomeBloc>(create: (_) => HomeBloc()),
        BlocProvider<OrderStatusCubit>(create: (_) => OrderStatusCubit()),
        BlocProvider<OrderStatusBloc>(create: (_) => OrderStatusBloc()),
        BlocProvider<RegisterBloc>(create: (_) => RegisterBloc()),
        BlocProvider<LoginBloc>(create: (_) => LoginBloc()),
        BlocProvider<LocationBloc>(create: (_) => LocationBloc()),
        BlocProvider<BannerBloc>(
          create: (_) => BannerBloc()..add(FetchBannersEvent()),
        ),
        BlocProvider<PopularProductsBloc>(create: (_) => PopularProductsBloc()),
        BlocProvider(create: (_) => PaymentBloc(PaymentApiService())),
        BlocProvider<SuggestionsBloc>(create: (_) => SuggestionsBloc()),
        BlocProvider(
          create: (context) => WishlistBloc()..add(LoadWishlist()),
          lazy: false, // Load immediately
        ),
        BlocProvider<OrderBloc>(
          // Add this
          create: (context) => OrderBloc(),
        ),
        BlocProvider<UserProfileBloc>(
          // Add this
          create: (context) => UserProfileBloc(),
        ),
        // Home-related blocs
        BlocProvider<CategoryBloc>(create: (_) => CategoryBloc()),
        BlocProvider<PopularProductsBloc>(create: (_) => PopularProductsBloc()),
        BlocProvider<OrderStatusBloc>(create: (_) => OrderStatusBloc()),
        BlocProvider<OffersBloc>(create: (_) => OffersBloc()),
        BlocProvider<BrandsBloc>(create: (_) => BrandsBloc()),
        BlocProvider<CouponsBloc>(create: (_) => CouponsBloc()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Wrap your MaterialApp.router with ScreenUtilInit
    return ScreenUtilInit(
      // Set the design size of your UI (e.g., the screen size in your Figma design)
      // This is a common size, but you should adjust it to match your design.
      designSize: const Size(360, 760),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        // 3. Return your MaterialApp.router from inside the builder
        // MultiBlocProvider(
        // providers: [
        //   BlocProvider(create: (context) => HomeBloc()),
        //   BlocProvider(create: (context) => CategoryBloc()),
        //   BlocProvider(create: (context) => PopularProductsBloc()),
        //   BlocProvider(create: (context) => OffersBloc()),
        //   BlocProvider(create: (context) => BrandsBloc()),
        //   BlocProvider(create: (context) => CouponsBloc()),
        //   BlocProvider(create: (context) => AddressBloc()),
        // ],
        // child:
        return ForceUpdateWidget(
          navigatorKey: GlobalSnackbar.navigatorKey,
          forceUpdateClient: ForceUpdateClient(
            fetchRequiredVersion: () async =>
                await ForceUpdateService.fetchMinAppVersion() ?? '2.2.9',
            iosAppStoreId: '6754846016', // Update with actual ID if known
          ),
          allowCancel: false,
          showForceUpdateAlert: (context, allowCancel) async => showDialog<bool>(
            context: context,
            barrierDismissible: allowCancel,
            builder: (context) => AlertDialog(
              title: const Text('Update Required'),
              content: const Text(
                'A new version of the app is available. Please update to continue.',
              ),
              actions: [
                if (allowCancel)
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Later'),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Update Now'),
                ),
              ],
            ),
          ),
          showStoreListing: (storeUrl) async {
            if (await canLaunchUrl(storeUrl)) {
              await launchUrl(storeUrl, mode: LaunchMode.externalApplication);
            }
          },
          child: RealtimeResumeBinding(
            child: MaterialApp.router(
            restorationScopeId: 'MyApp',
            title: EnvironmentalVariables.appName,
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
            // ...
            theme: ThemeData(
              primarySwatch: Colors.deepOrange,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              useMaterial3: true,
              fontFamily: 'Segoe UI',
              appBarTheme: const AppBarThemeData(
                backgroundColor: AppColors.primary,
                centerTitle: false,
                titleSpacing: 0,
                titleTextStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
            ),
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              physics: const BouncingScrollPhysics(), // smooth iOS-style scroll
            ),
            builder: (context, routeChild) {
              return SafeArea(
                top: false, // appbar manages the top
                child: routeChild!,
              );
            },
            // The 'child' is not needed here because routerConfig handles the UI
            //  ),
          ),
          ),
        );
      },
    );
  }
}
