import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/core/widgets/buttons/primary_button.dart';
import 'package:villag_kart/features/home/bloc/category_bloc/category_bloc.dart';
import 'package:villag_kart/features/home/bloc/category_bloc/category_state.dart';
import 'package:villag_kart/features/home/bloc/home_bloc/home_bloc.dart';
import 'package:villag_kart/features/home/model/category_model.dart';
import 'package:villag_kart/features/profile/bloc/order/order_bloc.dart';
import 'package:villag_kart/features/profile/bloc/order/order_event.dart';
import 'package:villag_kart/features/profile/bloc/order/order_state.dart';
import 'package:villag_kart/features/profile/bloc/rate_review/rate_review_bloc.dart';
import 'package:villag_kart/features/profile/model/order_history_model.dart';
import 'package:villag_kart/features/profile/view/order_cancelled_screen.dart';
import 'package:villag_kart/features/profile/view/order_details_screen.dart';
import 'package:villag_kart/features/profile/view/order_tracking_screen.dart';
import 'package:villag_kart/features/profile/view/rate_review_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color orangeColor = const Color(0xFFE46A0A);
  String? _currentFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _loadOrders(OrderBloc bloc) {
    bloc.add(FetchOrders(page: 1, limit: 20, status: _currentFilter));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Empty state — uses correct file: assets/images/empty-orders.svg
  // ---------------------------------------------------------------------------
  Widget _buildEmptyOrders() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(
              'assets/images/empty-orders.svg',
              width: 240,
              height: 190,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 42),
            Text(
              'No Orders Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 24,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Looks like you have not\n Made your menu yet",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            PrimaryButton(
              onPressed: () {
                final homeState = context.read<HomeBloc>().state;
                final pincode = homeState.pincode!;

                final categoryState = context.read<CategoryBloc>().state;
                final List<CategoryModel> allCategories = [
                  if (categoryState is CategoryLoaded)
                    ...categoryState.categories,
                ];

                if (allCategories.isNotEmpty) {
                  final firstCategory = allCategories.first;
                  context.pushNamed(
                    'searchrail',
                    extra: {
                      'categoryId': firstCategory.id,
                      'categoryName': firstCategory.name,
                      'pincode': pincode,
                      'allCategories': allCategories,
                    },
                  );
                } else {
                  debugPrint('Categories not loaded yet');
                }
              },
              label: 'Start Shopping',
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Active order card
  // ---------------------------------------------------------------------------
  Widget _buildOrderCard(Order order) {
    return GestureDetector(
      onTap: () {
        context.pushNamed('orderDetail', extra: order);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child:
                      order.items.isNotEmpty &&
                          order.items.first.product.images.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: order.items.first.product.images.first,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.shopping_bag,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.shopping_bag,
                            color: Colors.grey,
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              order.items.isNotEmpty
                                  ? order.items.first.product.name
                                  : 'Order',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,

                                color: Color(0xFF444444),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              _statusInfoIcon(order.status),
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(order.status),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  order.status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,

                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order.orderNumber,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFFE46A0A),

                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _formatDate(order.createdAt),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Store to delivery address
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.storeName,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF000000),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  height: 20,
                  width: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE3E3E3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward, size: 12),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.address.label,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF000000),
                        ),
                      ),
                      Text(
                        order.deliveryAddressText,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF000000),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              order.formattedItems,
              style: const TextStyle(fontSize: 11, color: Color(0xFF000000)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Total ',
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text: order.formattedAmount,
                          style: const TextStyle(color: Color(0xFF2C9E19)),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      if (order.isDelivered)
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: orangeColor),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: () {
                            context.pushNamed(
                              'rateReview',
                              extra: {
                                'productId': order.items.first.product.id,
                                'orderNumber': order.orderNumber,
                              },
                            );
                          },
                          child: const Text(
                            'Rate & Review',
                            style: TextStyle(
                              color: Color(0xFFE46A0A),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: order.isOngoing
                              ? const Color(0xFF2C9E19)
                              : order.status.toUpperCase() == 'PLACED'
                              ? const Color(0xFF2C9E19)
                              : const Color(0xFFE46A0A),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () {
                          if (order.isOngoing) {
                            context.pushNamed('orderTracking', extra: order);
                          } else if (order.status.toUpperCase() == 'PLACED') {
                            context.pushNamed('orderDetail', extra: order);
                          } else {
                            context.pushNamed('orderDetail', extra: order);
                          }
                        },
                        child: Text(
                          order.isOngoing
                              ? 'Track'
                              : order.status.toUpperCase() == 'PLACED'
                              ? 'View Order'
                              : 'Reorder',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanceledOrderCard(Order order) {
    return GestureDetector(
      onTap: () {
        context.pushNamed('orderCancelled', extra: order);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child:
                      order.items.isNotEmpty &&
                          order.items.first.product.images.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: order.items.first.product.images.first,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.shopping_bag,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.shopping_bag,
                            color: Colors.grey,
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              order.items.isNotEmpty
                                  ? order.items.first.product.name
                                  : 'Order',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,

                                color: Color(0xFF444444),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'CANCELLED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,

                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order.orderNumber,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFFE46A0A),

                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _formatDate(order.createdAt),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.storeName,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF000000),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  height: 20,
                  width: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE3E3E3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward, size: 12),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.address.label,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF000000),
                        ),
                      ),
                      Text(
                        order.deliveryAddressText,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF000000),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              order.formattedItems,
              style: const TextStyle(fontSize: 11, color: Color(0xFF000000)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 150),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //  RichText(
                  //     text: TextSpan(
                  //       style: const TextStyle(
                  //         fontSize: 12,
                  //         fontWeight: FontWeight.w600,
                  //       ),
                  //       children: [
                  //         const TextSpan(
                  //           text: 'Amount Refunded ',
                  //           style: TextStyle(color: Colors.black),
                  //         ),
                  //         TextSpan(
                  //           text: order.formattedAmount,
                  //           style: const TextStyle(color: Color(0xFF2C9E19)),
                  //         ),
                  //       ],
                  //     ),
                  //  ),
                  Row(
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: orangeColor),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          'Refund Info',
                          style: TextStyle(
                            color: Color(0xFFE46A0A),
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C9E19),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () {
                          context.pushNamed('orderDetail', extra: order);
                        },
                        child: const Text(
                          'Reorder',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'DELIVERED':
        return Colors.green;
      case 'RETURNED':
        return Colors.teal;
      case 'CANCELLED':
      case 'FAILED':
        return Colors.red;
      case 'CONFIRMED':
      case 'PROCESSING':
      case 'READY_FOR_PICKUP':
      case 'OUT_FOR_DELIVERY':
      case 'RETURN_INITIATED':
        return Colors.blue;
      case 'PENDING':
      case 'PLACED':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _detailStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Your order is awaiting confirmation';
      case 'CONFIRMED':
        return 'Your order has been confirmed';
      case 'PROCESSING':
        return 'Your order is being prepared';
      case 'READY_FOR_PICKUP':
        return 'Your order is ready for pickup';
      case 'OUT_FOR_DELIVERY':
      case 'ASSIGNED_TO_AGENT':
      case 'SHIPPED':
        return 'Your order is out for delivery';
      case 'RETURN_INITIATED':
        return 'A return has been initiated for your order';
      case 'DELIVERED':
        return 'Your order has been delivered successfully';
      case 'CANCELLED':
        return 'Your order has been cancelled';
      case 'FAILED':
        return 'Your order could not be processed';
      case 'RETURNED':
        return 'Your order has been returned';
      case 'PLACED':
        return 'Your order has been placed successfully';
      default:
        return 'Status unknown';
    }
  }

  Widget _statusInfoIcon(String status) {
    return Tooltip(
      message: _detailStatusText(status),
      preferBelow: true,
      verticalOffset: 30,
      triggerMode: TooltipTriggerMode.tap,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,

        fontWeight: FontWeight.w400,
      ),
      showDuration: const Duration(seconds: 3),
      child: const Icon(
        Icons.info_outline_rounded,
        size: 20,
        color: Color(0xFF000000),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${monthNames[date.month - 1]}, ${date.year}';
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderBloc(),
      child: Builder(
        builder: (context) {
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor: const Color(0xFFF8F9FA),
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(100),
                child: BlocBuilder<OrderBloc, OrderState>(
                  builder: (context, state) {
                    bool showTabs = false;

                    if (state is OrderLoaded && state.orders.isNotEmpty) {
                      showTabs = true;
                    }

                    return AppBar(
                      backgroundColor: Colors.white,
                      elevation: 0.5,
                      automaticallyImplyLeading: false,
                      titleSpacing: 0,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => context.pop(),
                      ),
                      title: const Text(
                        'Order History',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      // ✅ Show TabBar only if orders exist
                      bottom: showTabs
                          ? TabBar(
                              controller: _tabController,
                              indicatorColor: orangeColor,
                              indicatorWeight: 3.0,
                              labelColor: orangeColor,
                              unselectedLabelColor: Colors.grey,
                              tabs: const [
                                Tab(text: 'All Orders'),
                                Tab(text: 'Canceled'),
                              ],
                            )
                          : null,
                    );
                  },
                ),
              ),
              body: BlocBuilder<OrderBloc, OrderState>(
                builder: (context, state) {
                  final bloc = context.read<OrderBloc>();

                  if (state is OrderInitial) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _loadOrders(bloc);
                    });
                  }

                  if (state is OrderLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is OrderError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.errorMessage),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _loadOrders(bloc),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is OrderLoaded) {
                    final orders = state.orders;
                    if (orders.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async => _loadOrders(bloc),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.80,
                            child: _buildEmptyOrders(),
                          ),
                        ),
                      );
                    }

                    final canceledOrders = orders
                        .where((o) => o.isCancelled)
                        .toList();

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        // All Orders tab
                        RefreshIndicator(
                          onRefresh: () async => _loadOrders(bloc),
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: orders.length,
                            itemBuilder: (context, index) =>
                                _buildOrderCard(orders[index]),
                          ),
                        ),

                        // Cancelled orders tab
                        canceledOrders.isEmpty
                            ? const Center(child: Text('No canceled orders'))
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: canceledOrders.length,
                                itemBuilder: (context, index) =>
                                    _buildCanceledOrderCard(
                                      canceledOrders[index],
                                    ),
                              ),
                      ],
                    );
                  }

                  if (state is OrderEmpty) {
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildEmptyOrders(),
                        const Center(child: Text("No canceled orders")),
                      ],
                    );
                  }

                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
