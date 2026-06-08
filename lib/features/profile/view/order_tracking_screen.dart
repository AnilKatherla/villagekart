import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:villag_kart/core/realtime/consumer_realtime_hub.dart';
import 'package:villag_kart/features/profile/model/order_history_model.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key, required this.order});
  final Order order;

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final Color orangeColor = const Color(0xFFE46A0A);
  final Color greenColor = const Color(0xFF2C9E19);
  final Color greyColor = const Color(0xFF757575);

  late Order _order;
  late final void Function(ConsumerSocketEvent) _socketListener = _onSocket;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    ConsumerRealtimeHub.instance.addOrderListener(_order.id, _socketListener);
  }

  @override
  void dispose() {
    ConsumerRealtimeHub.instance.removeOrderListener(_order.id, _socketListener);
    super.dispose();
  }

  void _onSocket(ConsumerSocketEvent ev) {
    if (!mounted) {
      return;
    }
    if (ev.kind == 'status') {
      final st = ev.payload['status']?.toString();
      if (st != null && st.isNotEmpty) {
        setState(
          () => _order = _order.copyWith(status: st, updatedAt: DateTime.now()),
        );
      }
    } else if (ev.kind == 'location') {
      final loc = ev.payload['location'];
      double? lat;
      double? lng;
      if (loc is Map) {
        lat =
            (loc['lat'] as num?)?.toDouble() ??
            (loc['latitude'] as num?)?.toDouble();
        lng =
            (loc['lng'] as num?)?.toDouble() ??
            (loc['longitude'] as num?)?.toDouble();
      }
      Map<String, dynamic>? etaMap;
      final eta = ev.payload['eta'];
      if (eta is Map<String, dynamic>) {
        etaMap = eta;
      } else if (eta is Map) {
        etaMap = Map<String, dynamic>.from(eta);
      }
      setState(() {
        _order = _order.copyWith(
          liveRiderLat: lat,
          liveRiderLng: lng,
          liveRiderEta: etaMap,
          updatedAt: DateTime.now(),
        );
      });
    }
  }

  /// Fulfillment movement is reflected on [Order.delivery] while [Order.status]
  /// remains the consumer order lifecycle (e.g. OUT_FOR_DELIVERY).
  static const _enRouteDeliveryStatuses = <String>{
    'ASSIGNED',
    'ACCEPTED',
    'PICKUP_OTP_PENDING',
    'PICKED_UP',
    'IN_TRANSIT',
    'DELIVERY_OTP_PENDING',
    'RETURN_IN_TRANSIT',
    'RETURN_COMPLETED',
  };

  bool _deliveryEnRoute(Order order) =>
      _enRouteDeliveryStatuses.contains(order.delivery.status);

  bool _historyHasToStatus(Order order, String code) {
    final history = order.statusHistory;
    for (final raw in history) {
      if (raw is Map && raw['toStatus']?.toString() == code) {
        return true;
      }
    }
    return false;
  }

  List<Map<String, dynamic>> _getTimeline(Order order) {
    final timeline = <Map<String, dynamic>>[];

    final history = order.statusHistory;
    final hasHistory = history.isNotEmpty;
    if (hasHistory) {
      for (final raw in history) {
        if (raw is! Map) {
          continue;
        }
        final to = raw['toStatus']?.toString();
        if (to == null || to.isEmpty) {
          continue;
        }
        DateTime? at;
        final c = raw['createdAt'];
        if (c is String) {
          at = DateTime.tryParse(c);
        }
        final reason = raw['reason']?.toString();
        final notes = raw['notes']?.toString();
        timeline.add({
          'title': _historyTitle(to),
          'description': (reason != null && reason.isNotEmpty)
              ? reason
              : (notes != null && notes.isNotEmpty)
              ? notes
              : 'Order status: ${to.replaceAll('_', ' ')}',
          'timestamp': at ?? order.updatedAt,
          'completed': true,
        });
      }
    }

    if (!hasHistory) {
      timeline.add({
        'title': 'Order Placed',
        'description': 'Your order has been received',
        'timestamp': order.createdAt,
        'completed': true,
      });
      if (order.confirmedAt != null) {
        timeline.add({
          'title': 'Order Confirmed',
          'description': 'Order has been confirmed',
          'timestamp': order.confirmedAt,
          'completed': true,
        });
      }
      if (order.status == 'PROCESSING' || order.status == 'READY_FOR_PICKUP') {
        timeline.add({
          'title': 'Order Processed',
          'description': 'Seller is preparing your order',
          'timestamp': order.updatedAt,
          'completed': true,
        });
      }
      if (order.status == 'OUT_FOR_DELIVERY' || _deliveryEnRoute(order)) {
        timeline.add({
          'title': 'Out for delivery',
          'description': 'Delivery partner is on the way',
          'timestamp': order.updatedAt,
          'completed':
              order.status == 'DELIVERED' ||
              order.status == 'RETURNED' ||
              order.status == 'CANCELLED',
          'current':
              order.status != 'DELIVERED' &&
              order.status != 'CANCELLED' &&
              order.status != 'RETURNED',
        });
      }
    } else {
      if (order.confirmedAt != null &&
          !_historyHasToStatus(order, 'CONFIRMED')) {
        timeline.add({
          'title': 'Order Confirmed',
          'description': 'Order has been confirmed',
          'timestamp': order.confirmedAt,
          'completed': true,
        });
      }
      if ((order.status == 'PROCESSING' ||
              order.status == 'READY_FOR_PICKUP') &&
          !_historyHasToStatus(order, 'PROCESSING') &&
          !_historyHasToStatus(order, 'READY_FOR_PICKUP')) {
        timeline.add({
          'title': 'Order Processed',
          'description': 'Seller is preparing your order',
          'timestamp': order.updatedAt,
          'completed': true,
        });
      }
      if ((order.status == 'OUT_FOR_DELIVERY' || _deliveryEnRoute(order)) &&
          !_historyHasToStatus(order, 'OUT_FOR_DELIVERY')) {
        timeline.add({
          'title': 'Out for delivery',
          'description': 'Delivery partner is on the way',
          'timestamp': order.updatedAt,
          'completed':
              order.status == 'DELIVERED' ||
              order.status == 'RETURNED' ||
              order.status == 'CANCELLED',
          'current':
              order.status != 'DELIVERED' &&
              order.status != 'CANCELLED' &&
              order.status != 'RETURNED',
        });
      }
    }

    if (order.status == 'DELIVERED' &&
        !_historyHasToStatus(order, 'DELIVERED')) {
      timeline.add({
        'title': 'Delivered',
        'description': 'Order delivered successfully',
        'timestamp': order.updatedAt,
        'completed': true,
        'current': true,
      });
    }

    if (order.status == 'RETURN_INITIATED' &&
        !_historyHasToStatus(order, 'RETURN_INITIATED')) {
      timeline.add({
        'title': 'Return initiated',
        'description': 'A return is being processed for this order',
        'timestamp': order.updatedAt,
        'completed': false,
        'current': true,
      });
    }

    if (order.status == 'RETURNED' && !_historyHasToStatus(order, 'RETURNED')) {
      timeline.add({
        'title': 'Returned',
        'description': 'This order has been returned',
        'timestamp': order.updatedAt,
        'completed': true,
        'current': true,
      });
    }

    if (order.status == 'CANCELLED' &&
        !_historyHasToStatus(order, 'CANCELLED')) {
      timeline.add({
        'title': 'Cancelled',
        'description': 'Order has been cancelled',
        'timestamp': order.cancelledAt,
        'completed': true,
        'current': true,
      });
    }

    if (order.status == 'FAILED' && !_historyHasToStatus(order, 'FAILED')) {
      timeline.add({
        'title': 'Failed',
        'description': 'This order could not be completed',
        'timestamp': order.updatedAt,
        'completed': true,
        'current': true,
      });
    }

    return timeline;
  }

  String _historyTitle(String toStatus) {
    switch (toStatus) {
      case 'PLACED':
        return 'Order placed';
      case 'CONFIRMED':
        return 'Order confirmed';
      case 'PROCESSING':
        return 'Processing';
      case 'READY_FOR_PICKUP':
        return 'Ready for pickup';
      case 'OUT_FOR_DELIVERY':
        return 'Out for delivery';
      case 'DELIVERED':
        return 'Delivered';
      case 'RETURN_INITIATED':
        return 'Return initiated';
      case 'RETURNED':
        return 'Returned';
      case 'CANCELLED':
        return 'Cancelled';
      case 'FAILED':
        return 'Failed';
      default:
        return toStatus.replaceAll('_', ' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeline = _getTimeline(_order);
    final isCancelledOrder = _order.status == 'CANCELLED';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(context),
        ),
        title: Text(
          'Track Order #${_order.orderNumber}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Order Summary
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFF8F9FA),
            child: Row(
              children: [
                // Product Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child:
                      _order.items.isNotEmpty &&
                          _order.items.first.product.images.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: _order.items.first.product.images.first,
                            fit: BoxFit.cover,
                            placeholder: (context, url) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorWidget: (context, url, error) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.shopping_bag,
                                  color: Colors.grey,
                                ),
                              );
                            },
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _order.items.isNotEmpty
                            ? _order.items.first.product.name
                            : 'Order',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_order.items.length} item${_order.items.length > 1 ? 's' : ''}',
                        style: TextStyle(fontSize: 12, color: greyColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _order.formattedAmount,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C9E19),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Tracking Timeline
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  isCancelledOrder ? 'Cancellation Timeline' : 'Order Timeline',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTimeline(timeline),
                const SizedBox(height: 24),

                // Delivery Address
                if (!isCancelledOrder)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Delivery Address',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _order.address.line1,
                          style: TextStyle(fontSize: 13, color: greyColor),
                        ),
                        const SizedBox(height: 4),
                        if (_order.address.line2.isNotEmpty)
                          Text(
                            _order.address.line2,
                            style: TextStyle(fontSize: 13, color: greyColor),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          '${_order.address.city}, ${_order.address.state} - ${_order.address.pincode}',
                          style: TextStyle(fontSize: 13, color: greyColor),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(List<Map<String, dynamic>> timeline) {
    return Column(
      children: List.generate(timeline.length, (index) {
        final step = timeline[index];
        final isCompleted = step['completed'] == true;
        final isCurrent = step['current'] == true;
        final isLast = index == timeline.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline line and dot
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? greenColor : Colors.grey[300],
                    border: isCurrent
                        ? Border.all(color: greenColor, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      isCompleted
                          ? Icons.check
                          : (isCurrent ? Icons.circle : Icons.circle_outlined),
                      size: isCurrent ? 12 : 16,
                      color: isCompleted ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 50,
                    color: isCompleted ? greenColor : Colors.grey[300],
                  ),
              ],
            ),
            const SizedBox(width: 16),

            // Status details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['title']!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isCompleted ? Colors.black : greyColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step['description']!,
                      style: TextStyle(fontSize: 12, color: greyColor),
                    ),
                    if (step['timestamp'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _formatDateTime(step['timestamp']),
                          style: TextStyle(fontSize: 11, color: greyColor),
                        ),
                      ),
                    if (isCurrent) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: greenColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: greenColor.withOpacity(0.3),
                          ),
                        ),
                        child: const Text(
                          'Current Status',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF2C9E19),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  String _formatDateTime(DateTime date) {
    final monthNames = [
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
    return '${date.day} ${monthNames[date.month - 1]}, ${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
