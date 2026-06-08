import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/features/cart/bloc/promocode_bloc/promocode_api_service.dart';
import 'package:villag_kart/features/cart/bloc/promocode_bloc/promocode_event.dart';
import 'package:villag_kart/features/cart/model/promocode_model.dart';
import 'promocode_state.dart';

class PromoCodeBloc extends Bloc<PromoCodeEvent, PromoCodeState> {
  PromoCodeBloc() : super(PromoCodeInitial()) {
    on<FetchCouponsEvent>(_onFetchCoupons);
    on<RefreshCouponsEvent>(_onRefreshCoupons);
    on<ApplyCouponEvent>(_onApplyCoupon);
    on<RemoveCouponEvent>(_onRemoveCoupon);
    on<ValidateCouponEvent>(_onValidateCoupon);
  }

  // ---------------------------------------------------------------------------
  // FETCH COUPONS
  // ---------------------------------------------------------------------------
  Future<void> _onFetchCoupons(
    FetchCouponsEvent event,
    Emitter<PromoCodeState> emit,
  ) async {
    try {
      emit(PromoCodeLoading());

      final result = await PromoCodeService.fetchCoupons(event.pincode);

      final personalized = result['personalized'] as List<CouponModel>;
      final global = result['global'] as List<CouponModel>;

      if (personalized.isEmpty && global.isEmpty) {
        emit(PromoCodeEmpty(message: 'No promo codes available'));
        return;
      }

      emit(
        PromoCodeSuccess(
          personalizedCoupons: personalized,
          globalCoupons: global,
        ),
      );
    } catch (e) {
      emit(PromoCodeFailure(e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // REFRESH COUPONS (KEEP APPLIED COUPON)
  // ---------------------------------------------------------------------------
  Future<void> _onRefreshCoupons(
    RefreshCouponsEvent event,
    Emitter<PromoCodeState> emit,
  ) async {
    try {
      CouponModel? appliedCoupon;
      double? discountAmount;

      if (state is PromoCodeSuccess) {
        final current = state as PromoCodeSuccess;
        appliedCoupon = current.appliedCoupon;
        emit(
          PromoCodeRefreshing(
            personalizedCoupons: current.personalizedCoupons,
            globalCoupons: current.globalCoupons,
            appliedCoupon: appliedCoupon,
          ),
        );
      } else {
        emit(PromoCodeLoading());
      }

      final result = await PromoCodeService.fetchCoupons(event.pincode);

      final personalized = result['personalized'] as List<CouponModel>;
      final global = result['global'] as List<CouponModel>;

      if (appliedCoupon != null) {
        if (_isCouponValid(appliedCoupon, event.cartTotal)) {
          discountAmount = _calculateDiscount(appliedCoupon, event.cartTotal);
        } else {
          appliedCoupon = null;
        }
      }

      emit(
        PromoCodeSuccess(
          personalizedCoupons: personalized,
          globalCoupons: global,
          appliedCoupon: appliedCoupon,
          discountAmount: discountAmount,
        ),
      );
    } catch (e) {
      emit(PromoCodeFailure(e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // APPLY COUPON
  // ---------------------------------------------------------------------------
  Future<void> _onApplyCoupon(
    ApplyCouponEvent event,
    Emitter<PromoCodeState> emit,
  ) async {
    final current = state;

    if (current is! PromoCodeSuccess) {
      emit(PromoCodeFailure('Please load coupons first'));
      return;
    }

    final CouponModel coupon;
    try {
      coupon = current.allCoupons.firstWhere(
        (c) => c.code.toUpperCase() == event.couponCode.toUpperCase(),
      );
    } catch (_) {
      emit(CouponValidationError('Invalid coupon code'));
      emit(current);
      return;
    }

    if (!_isCouponValid(coupon, event.cartTotal)) {
      emit(
        CouponValidationError(
          'Minimum order value of ₹${coupon.minOrderValue} required',
          coupon: coupon,
        ),
      );
      emit(current);
      return;
    }

    final discount = _calculateDiscount(coupon, event.cartTotal);

    emit(
      CouponAppliedSuccess(
        coupon: coupon,
        discountAmount: discount,
        message:
            'Coupon ${coupon.code} applied! You saved ₹${discount.toStringAsFixed(2)}',
      ),
    );

    emit(current.copyWith(appliedCoupon: coupon, discountAmount: discount));
  }

  // ---------------------------------------------------------------------------
  // REMOVE COUPON
  // ---------------------------------------------------------------------------
  Future<void> _onRemoveCoupon(
    RemoveCouponEvent event,
    Emitter<PromoCodeState> emit,
  ) async {
    final current = state;

    if (current is PromoCodeSuccess) {
      emit(CouponRemovedSuccess('Coupon removed'));
      emit(current.copyWith(clearAppliedCoupon: true));
    }
  }

  // ---------------------------------------------------------------------------
  // VALIDATE COUPON (ON CART CHANGE)
  // ---------------------------------------------------------------------------
  Future<void> _onValidateCoupon(
    ValidateCouponEvent event,
    Emitter<PromoCodeState> emit,
  ) async {
    final current = state;

    if (current is! PromoCodeSuccess || current.appliedCoupon == null) return;

    final coupon = current.appliedCoupon!;

    if (!_isCouponValid(coupon, event.cartTotal)) {
      emit(
        CouponValidationError(
          'Coupon removed due to cart change',
          coupon: coupon,
        ),
      );
      emit(current.copyWith(clearAppliedCoupon: true));
    }
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------
  bool _isCouponValid(CouponModel coupon, double cartTotal) {
    if (coupon.isExpired) return false;
    if (cartTotal < coupon.minOrderValue) return false;
    if (coupon.totalRemainingUses != null && coupon.totalRemainingUses! <= 0)
      return false;
    return true;
  }

  double _calculateDiscount(CouponModel coupon, double cartTotal) {
    double discount;

    if (coupon.type == 'PERCENTAGE') {
      discount = (cartTotal * coupon.value) / 100;
      if (coupon.maxDiscount != null && discount > coupon.maxDiscount!) {
        discount = coupon.maxDiscount!.toDouble();
      }
    } else {
      discount = coupon.value.toDouble();
    }

    return discount > cartTotal ? cartTotal : discount;
  }
}
