/// **************************************************************
/// @author: Venkat Phanitapu
/// @date: 12 November 2025
/// @project: VillagKart
/// @description: [Widget or ViewModel description]
/// **************************************************************
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:villag_kart/core/screens/main_shell.dart';
import 'package:villag_kart/core/screens/splash_screen.dart';
import 'package:villag_kart/features/address/address_list_screen.dart';
import 'package:villag_kart/features/cart/bloc/cart_bloc.dart';
import 'package:villag_kart/features/cart/bloc/create_order_pickup.dart/create_order_pickup_bloc.dart';
import 'package:villag_kart/features/cart/bloc/create_scheduled_order/create_scheduled_order_bloc.dart';
import 'package:villag_kart/features/cart/bloc/delivery_bloc/delivery_bloc.dart';
import 'package:villag_kart/features/cart/bloc/pickup_delivery_bloc/pickup_slot_bloc.dart';
import 'package:villag_kart/features/cart/bloc/promocode_bloc/promocode_bloc.dart';
import 'package:villag_kart/features/cart/bloc/scheduled_delivery/scheduled_delivery_bloc.dart';
import 'package:villag_kart/features/cart/services/create_order_pickup_api_service.dart';
import 'package:villag_kart/features/cart/services/create_schedule_order_api.dart';
import 'package:villag_kart/features/cart/services/delivery_api_service.dart';
import 'package:villag_kart/features/cart/services/pickup_slot_api_service.dart';
import 'package:villag_kart/features/cart/services/scheduled_delivery_api.dart';
import 'package:villag_kart/features/cart/view/delivery_option_screen.dart';
import 'package:villag_kart/features/cart/view/review_items_page.dart';
import 'package:villag_kart/features/chatSupport/chat.dart';
import 'package:villag_kart/features/chatSupport/chatSupport.dart';
import 'package:villag_kart/features/home/bloc/offers_bloc/offers_bloc.dart';
import 'package:villag_kart/features/home/bloc/popular_products_bloc/popular_products_bloc.dart';
import 'package:villag_kart/features/home/model/category_model.dart';
import 'package:villag_kart/features/home/sections/offers_screen.dart';
import 'package:villag_kart/features/home/sections/popular_product_screen.dart';
import 'package:villag_kart/features/inviteFriends/invite.dart';
import 'package:villag_kart/features/location/bloc/location_bloc.dart';
import 'package:villag_kart/features/map/view/map_route_screen.dart';
import 'package:villag_kart/features/onboarding/SupportScreen.dart';
import 'package:villag_kart/features/onboarding/onboardingScreen.dart';
import 'package:villag_kart/features/payment/Service/payment_api_service.dart';
import 'package:villag_kart/features/payment/bloc/payment_bloc.dart';
import 'package:villag_kart/features/payment/view/razorpay_payment_screen.dart';
import 'package:villag_kart/features/profile/bloc/faq_page/faq_bloc.dart';
import 'package:villag_kart/features/profile/bloc/faq_page/faq_event.dart';
import 'package:villag_kart/features/profile/bloc/faq_page/faq_service.dart';
import 'package:villag_kart/features/profile/bloc/order/order_bloc.dart';
import 'package:villag_kart/features/profile/bloc/order/order_event.dart';
import 'package:villag_kart/features/profile/bloc/wishlist/wishlist_bloc.dart';
import 'package:villag_kart/features/profile/model/order_history_model.dart';
import 'package:villag_kart/features/profile/view/about_us_screen.dart';
import 'package:villag_kart/features/profile/view/add_address.dart';
import 'package:villag_kart/features/profile/view/faq_screen.dart';
import 'package:villag_kart/features/profile/view/invoice_screen.dart';
import 'package:villag_kart/features/profile/view/legal_terms_screen.dart';
import 'package:villag_kart/features/profile/view/manage_address_screen.dart';
import 'package:villag_kart/features/profile/view/order_cancelled_screen.dart';
import 'package:villag_kart/features/profile/view/order_details_screen.dart';
import 'package:villag_kart/features/profile/view/order_history_screen.dart';
import 'package:villag_kart/features/profile/view/order_tracking_screen.dart';
import 'package:villag_kart/features/profile/view/rate_review_screen.dart';
import 'package:villag_kart/features/profile/view/refunds_screen.dart';
import 'package:villag_kart/features/profile/view/send_feedback_screen.dart';
import 'package:villag_kart/features/profile/view/suggestion.dart';
import 'package:villag_kart/features/home/model/product_response.dart';
import 'package:villag_kart/features/location/screens/location_picker_screen.dart';
import 'package:villag_kart/features/notificationSettings/notificationSettings.dart';
import 'package:villag_kart/features/onboard/bloc/login_bloc.dart';
import 'package:villag_kart/features/onboard/phone_entry_screen.dart';
import 'package:villag_kart/features/payment/view/payment_failure.dart';
import 'package:villag_kart/features/payment/view/payment_options.dart';
import 'package:villag_kart/features/payment/view/payment_success.dart';
import 'package:villag_kart/features/profile/view/wishlist_screen.dart';
import 'package:villag_kart/features/quick_action_screens/assistant_help.dart';
import 'package:villag_kart/features/quick_action_screens/cart_share.dart';
import 'package:villag_kart/features/quick_action_screens/daily_deals.dart';
import 'package:villag_kart/features/quick_action_screens/offers_and_promos.dart';
import 'package:villag_kart/features/quick_action_screens/weekly_special.dart';
import 'package:villag_kart/features/register/register_screen.dart';
import 'package:villag_kart/features/search/view/pages/product_detail_page.dart';
import 'package:villag_kart/features/search/view/pages/search_product_rail.dart';
import 'package:villag_kart/features/search/view/pages/search_screen.dart';
import 'package:villag_kart/features/serviceCheck/service_check_screen.dart';
import 'package:villag_kart/core/utils/global_snackbar.dart';

class AppRouter {
  static final router = GoRouter(
    navigatorKey: GlobalSnackbar.navigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnBoardingScreen(),
      ),

      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: '/otp',
        name: 'otp',
        builder: (context, state) => BlocProvider(
          create: (context) => LoginBloc(),
          child: const PhoneEntryScreen(),
        ),
      ),
      GoRoute(
        path: '/deny-location',
        name: 'denyLocation',
        builder: (context, state) {
          final onAllow = state.extra as VoidCallback;

          return DenyLocationScreen(onAllow: onAllow);
        },
      ),
      GoRoute(
        path: '/serviceability',
        name: 'serviceability',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ServiceAvailabilityCheckScreen(
            initialLatLng: extra?['initialLatLng'] as LatLng?,
            address: extra?['address'] as String?,
            pincode: extra?['pincode'] as String?,
            label: extra?['label'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/location',
        name: 'location',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;

          return LocationPickerScreen(
            initialAddress: data?['initialAddress'],
            initialPincode: data?['initialPincode'],
            initialLatLng: data?['initialLatLng'],
          );
        },
      ),
      GoRoute(
        path: '/addresslist',
        name: 'addresslist',
        builder: (context, state) {
          final _address = state.extra as String;
          return AddressListScreen(address: _address);
        },
      ),
      GoRoute(
        path: '/manage-address',
        name: 'manageAddress',
        builder: (context, state) {
          return const ManageAddressScreen();
        },
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) {
          // --- START OF FIX ---

          // 1. Default to null if state.extra is not the expected type.
          String? address;
          Map<String, dynamic>? orderInfo;
          int? tabIndex; // Add this

          final extra = state.extra;
          if (extra is String) {
            address = extra;
            orderInfo = null;
          } else if (extra is Map<String, dynamic>) {
            address = extra['address'] as String?;
            orderInfo = extra['orderInfo'] as Map<String, dynamic>?;
            tabIndex = extra['tabIndex'] as int?; // Extract tabIndex
          }
          // 5. Pass the extracted (and now correctly typed) data to MainShell.
          return MainShell(
            address: address,
            orderInfo: orderInfo,
            tabIndex: tabIndex, // Pass to shell
          );
        },
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) {
          return const SearchScreen();
        },
      ),
      GoRoute(
        path: '/searchrail',
        name: 'searchrail',
        builder: (context, state) {
          // Extract parameters from state.extra or query parameters
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final categoryId = extra['categoryId'] as String? ?? '';
          final categoryName = extra['categoryName'] as String? ?? 'Products';
          final pincode = extra['pincode'] as String? ?? '';
          final allCategories =
              extra['allCategories'] as List<CategoryModel>? ?? [];
          return SearchProductRail(
            categoryId: categoryId,
            categoryName: categoryName,
            pincode: pincode,
            allCategories: allCategories,
          );
        },
      ),
      GoRoute(
        path: '/proddetail',
        name: 'proddetail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final prod = extra['prod'] as Product;
          final pincode = extra['pincode'] as String? ?? '';
          return ProductDetailPage(product: prod, pincode: pincode);
        },
      ),
      GoRoute(
        name: 'popularProducts',
        path: '/popular-products',
        builder: (context, state) {
          final pincode = state.extra as String? ?? '';

          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: context.read<PopularProductsBloc>()),
              BlocProvider.value(value: context.read<WishlistBloc>()),
            ],
            child: PopularProductsScreen(pincode: pincode),
          );
        },
      ),
      GoRoute(
        name: 'offers',
        path: '/offers',
        builder: (context, state) {
          final pincode = state.extra as String? ?? '';
          return OffersScreen(pincode: pincode);
        },
      ),
      GoRoute(
        name: 'addAddress',
        path: '/add-address',
        builder: (context, state) {
          final address = state.extra as Address?;

          return AddAddressScreen(existingAddress: address);
        },
      ),
      GoRoute(
        path: '/reviewitem',
        name: 'reviewitem',
        builder: (context, state) {
          return MultiBlocProvider(
            providers: [
              // BlocProvider.value(
              //   value: context.read<CartBloc>(),
              // ),
              BlocProvider(create: (_) => PromoCodeBloc()),
            ],
            child: Builder(
              // 🔥 IMPORTANT FIX
              builder: (context) {
                return ReviewItemsPage();
              },
            ),
          );
        },
      ),
      GoRoute(
        name: 'paymentOption',
        path: '/paymentOption',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;

          final double payableAmount =
              (data?['amount'] as num?)?.toDouble() ?? 0.0;

          final String orderId = data?['orderId'] ?? '';

          return BlocProvider(
            create: (context) => PaymentCubit(),
            child: PaymentOptionsPage(
              amount: payableAmount,
              orderId: orderId, // 🔥 pass orderId also
            ),
          );
        },
      ),
      GoRoute(
        name: 'razorpay',
        path: '/razorpay',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;

          if (data == null) {
            return const Scaffold(
              body: Center(child: Text('Payment data missing')),
            );
          }

          final orderId = data['orderId']?.toString() ?? '';
          final razorpayOrderId = data['razorpayOrderId']?.toString() ?? '';
          final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;

          if (orderId.isEmpty || razorpayOrderId.isEmpty || amount == 0) {
            return const Scaffold(
              body: Center(child: Text('Invalid payment data')),
            );
          }

          return BlocProvider<PaymentBloc>(
            create: (context) => PaymentBloc(PaymentApiService()),
            child: RazorpayPaymentScreen(
              orderId: orderId,
              razorpayOrderId: razorpayOrderId,
              amount: amount,
            ),
          );
        },
      ),

      GoRoute(
        path: '/success',
        name: 'success',
        builder: (context, state) {
          final orderId = state.extra as String;
          return PaymentSuccessPage(orderId: orderId); // ✅ no const
        },
      ),
      GoRoute(
        name: 'orderHistory',
        path: '/order-history',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => OrderBloc()..add(FetchOrders(page: 1, limit: 20)),
            child: const OrderHistoryScreen(),
          );
        },
      ),
      GoRoute(
        name: 'invoice',
        path: '/invoice',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};

          final orderId = extra['orderId'] as String? ?? '';
          final orderNumber = extra['orderNumber'] as String? ?? '';

          return InvoiceScreen(orderId: orderId, orderNumber: orderNumber);
        },
      ),
      GoRoute(
        name: 'orderDetail',
        path: '/order-detail',
        builder: (context, state) {
          final order = state.extra as Order;

          return OrderDetailScreen(order: order);
        },
      ),
      GoRoute(
        path: '/rate-review',
        name: 'rateReview',
        builder: (context, state) {
          final productId = state.uri.queryParameters['productId'] ?? '';
          final orderNumber = state.uri.queryParameters['orderNumber'] ?? '';

          return RateAndReviewScreen(
            productId: productId,
            orderNumber: orderNumber,
          );
        },
      ),

      GoRoute(
        path: '/order-cancelled',
        name: 'orderCancelled',
        builder: (context, state) {
          final order = state.extra as Order;

          return OrderCancelledScreen(order: order);
        },
      ),
      GoRoute(
        path: '/wishlist',
        name: 'wishlist',
        builder: (context, state) {
          return const WishlistScreen();
        },
      ),
      GoRoute(
        path: '/router',
        name: 'router',
        builder: (context, state) {
          final orderId = state.extra as String;
          return MapRouteScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/failure',
        name: 'failure',
        builder: (context, state) {
          return const PaymentFailurePage();
        },
      ),
      GoRoute(
        name: 'somethingWentWrong',
        path: '/somethingWentWrong',
        builder: (context, state) {
          return const SomethingWentWrongScreen();
        },
      ),
      GoRoute(
        name: 'staticSupport',
        path: '/staticSupport',
        builder: (context, state) {
          return const StaticSupportScreen();
        },
      ),

      GoRoute(
        path: '/invite-friends',
        name: 'inviteFriends',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;

          return InviteFriendsScreen(
            referralCode: data['referralCode'],
            shareMessage:
                data['shareMessage'] ?? 'Join me using my referral code:',
          );
        },
      ),
      GoRoute(
        path: '/notificationsettings',
        name: 'notificationsettings',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),

      GoRoute(
        path: '/chatsupport',
        name: 'chatsupport',
        builder: (context, state) => const LagroceSupportScreen(),
      ),

      GoRoute(
        path: '/chatscreen',
        name: 'chatscreen',
        builder: (context, state) =>
            ChatScreen(profileImagePath: state.extra as String?),
      ),

      GoRoute(
        path: '/suggestions',
        name: 'suggestions',
        builder: (context, state) => const SuggestionScreen(),
      ),

      GoRoute(
        path: '/refunds',
        name: 'refunds',
        builder: (context, state) => const RefundsScreen(),
      ),

      GoRoute(
        path: '/aboutUs',
        name: 'aboutUs',
        builder: (context, state) => const AboutUsScreen(),
      ),

      GoRoute(
        path: '/deliveryOptions',
        name: 'deliveryOptions',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          final double itemsTotal =
              (data?['itemsTotal'] as num?)?.toDouble() ?? 0.0;
          final double promo = (data?['promo'] as num?)?.toDouble() ?? 0.0;
          final String instruction = data?['instruction'] ?? '';
          final String couponCode = data?['couponCode'] ?? '';

          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => DeliveryBloc(DeliveryApiService())),
              BlocProvider(
                create: (_) => DeliverySlotBloc(DeliverySlotApiService()),
              ),
              BlocProvider(
                create: (_) => PickupSlotBloc(PickupSlotApiService()),
              ),
              BlocProvider(
                create: (_) => CreateScheduledOrderBloc(
                  apiService: CreateScheduledOrderApiService(),
                ),
              ),
              BlocProvider(
                create: (_) =>
                    CreateOrderPickupBloc(CreateOrderPickupApiService()),
              ),
              BlocProvider(create: (_) => LocationBloc()),
            ],
            child: DeliveryOptionsScreen(
              itemsTotal: itemsTotal,
              promo: promo,
              taxes: data?['taxes'] != null
                  ? (data!['taxes'] as num).toDouble()
                  : 0.0, // Handle taxes
              instruction: instruction,
              couponCode: couponCode,
            ),
          );
        },
      ),

      GoRoute(
        path: '/faq',
        name: 'faq',
        builder: (context, state) {
          return BlocProvider(
            create: (context) =>
                DeliveryFaqBloc(DeliveryFaqApiService())
                  ..add(FetchDeliveryFaqs()), // This triggers the API
            child: const FAQScreen(),
          );
        },
      ),
      GoRoute(
        path: '/send-feedback',
        name: 'sendFeedback',
        builder: (context, state) {
          return const SendFeedbackScreen();
        },
      ),
      GoRoute(
        path: '/legal',
        name: 'legal',
        builder: (context, state) => const LegalTermsScreen(),
      ),
      GoRoute(
        path: '/order-tracking',
        builder: (context, state) {
          final order = state.extra as Order;
          return OrderTrackingScreen(order: order);
        },
      ),

      GoRoute(
        path: '/offersAndPromo',
        builder: (context, state) => const OffersAndPromos(),
      ),

      GoRoute(
        path: '/dailyDeals',
        builder: (context, state) => const DailyDeals(),
      ),

      GoRoute(
        path: '/ShareCart',
        builder: (context, state) => const ShareCart(),
      ),

      GoRoute(
        path: '/AssistantHelp',
        builder: (context, state) => const AssistantHelp(),
      ),

      GoRoute(
        path: '/weeklyMarket',
        builder: (context, state) => const Weeklymarket(),
      ),
    ],
    errorBuilder: (context, state) =>
        const Scaffold(body: Center(child: Text('Page not found'))),
  );
}
