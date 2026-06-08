import 'dart:async';
import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:villag_kart/core/realtime/consumer_realtime_constants.dart';
import 'package:villag_kart/core/realtime/realtime_suppression.dart';
import 'package:villag_kart/core/storage/shared_preferences.dart';
import 'package:villag_kart/environmental_variables.dart';

/// Normalized realtime payloads for UI / BLoC.
class ConsumerSocketEvent {
  ConsumerSocketEvent({required this.kind, required this.payload});

  /// `status` | `location` | `notification`
  final String kind;
  final Map<String, dynamic> payload;
}

/// Socket.IO hub for `/consumer` — join-order-tracking, dedupe, reconnect rejoin.
class ConsumerRealtimeHub {
  ConsumerRealtimeHub._();
  static final ConsumerRealtimeHub instance = ConsumerRealtimeHub._();

  io.Socket? _socket;
  final Set<String> _joinedOrders = {};
  final Map<String, List<void Function(ConsumerSocketEvent)>> _orderListeners =
      {};
  final List<void Function(ConsumerSocketEvent)> _globalListeners = [];
  final Map<String, String> _lastDedupe = {};
  Timer? _pollFallbackTimer;


  bool get isConnected => _socket?.connected == true;

  void addGlobalListener(void Function(ConsumerSocketEvent) fn) {
    _globalListeners.add(fn);
  }

  void removeGlobalListener(void Function(ConsumerSocketEvent) fn) {
    _globalListeners.remove(fn);
  }

  void addOrderListener(String orderId, void Function(ConsumerSocketEvent) fn) {
    final id = orderId.trim();
    if (id.isEmpty) {
      return;
    }
    _orderListeners.putIfAbsent(id, () => []).add(fn);
    unawaited(
      ensureConnected().then((_) {
        _joinOrder(id);
      }),
    );
  }

  void removeOrderListener(
    String orderId,
    void Function(ConsumerSocketEvent) fn,
  ) {
    final id = orderId.trim();
    final list = _orderListeners[id];
    if (list == null) {
      return;
    }
    list.remove(fn);
    if (list.isEmpty) {
      _orderListeners.remove(id);
      _leaveOrder(id);
    }
  }

  /// When socket stays offline, call [onTick] periodically (e.g. refetch order REST).
  void setPollingFallback({
    Duration interval = const Duration(seconds: 12),
    void Function()? onTick,
  }) {
    _pollFallbackTimer?.cancel();
    // _pollFallbackCallback = onTick; // Removed as it was unused
    if (onTick == null) {
      return;
    }
    _pollFallbackTimer = Timer.periodic(interval, (_) {
      if (!isConnected) {
        try {
          onTick();
        } catch (e, st) {
          log('[RealtimeHub] poll fallback error', error: e, stackTrace: st);
        }
      }
    });
  }

  void clearPollingFallback() {
    _pollFallbackTimer?.cancel();
    _pollFallbackTimer = null;
  }

  Future<void> ensureConnected() async {
    final origin = EnvironmentalVariables.resolvedSocketOrigin();
    final token = await SharedPrefs.getAccessToken();
    if (origin.isEmpty || token == null || token.isEmpty) {
      log('[RealtimeHub] skip connect — missing origin or token');
      return;
    }
    if (_socket != null && _socket!.connected) {
      return;
    }

    final base = Uri.parse(origin);
    final uri = base
        .replace(path: ConsumerRealtimeEvents.consumerNamespace)
        .toString();

    _socket?.dispose();
    _socket = io.io(
      uri,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableForceNew()
          .setAuth({'token': token})
          .enableReconnection()
          .setReconnectionAttempts(12)
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(20000)
          .build(),
    );

    _socket!.onConnect((_) {
      log('[RealtimeHub] connected');
      _joinedOrders.forEach(_emitJoin);
    });

    _socket!.onReconnect((_) {
      log('[RealtimeHub] reconnect — rejoin ${_joinedOrders.length} orders');
      _joinedOrders.forEach(_emitJoin);
    });

    _socket!.onDisconnect((_) => log('[RealtimeHub] disconnected'));

    _socket!.on(ConsumerRealtimeEvents.orderStatus, (raw) {
      _handlePayload('status', _asMap(raw));
    });
    _socket!.on(ConsumerRealtimeEvents.riderLocation, (raw) {
      _handlePayload('location', _asMap(raw));
    });
    _socket!.on(ConsumerRealtimeEvents.notification, (raw) {
      _dispatchGlobal(
        ConsumerSocketEvent(kind: 'notification', payload: _asMap(raw)),
      );
    });

    // Legacy alias from server
    _socket!.on('order-status-update', (raw) {
      _handlePayload('status', _asMap(raw));
    });
    _socket!.on('location-update', (raw) {
      _handlePayload('location', _asMap(raw));
    });

    _socket!.connect();
  }

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return {};
  }

  void _handlePayload(String kind, Map<String, dynamic> payload) {
    final orderId = payload['orderId']?.toString() ?? '';
    if (orderId.isNotEmpty && (kind == 'status' || kind == 'location')) {
      RealtimeSuppression.touchOrder(orderId);
    }
    final dedupeKey =
        '$kind:${payload['correlationId'] ?? payload['eventId'] ?? ''}:${payload['status'] ?? ''}:${payload['timestamp'] ?? ''}';
    if (orderId.isNotEmpty) {
      final prev = _lastDedupe[orderId];
      if (prev == dedupeKey) {
        return;
      }
      _lastDedupe[orderId] = dedupeKey;
    }
    final ev = ConsumerSocketEvent(kind: kind, payload: payload);
    if (orderId.isNotEmpty) {
      final list = _orderListeners[orderId];
      if (list != null) {
        for (final fn in List<void Function(ConsumerSocketEvent)>.from(list)) {
          try {
            fn(ev);
          } catch (e, st) {
            log('[RealtimeHub] listener error', error: e, stackTrace: st);
          }
        }
      }
    }
    _dispatchGlobal(ev);
  }

  void _dispatchGlobal(ConsumerSocketEvent ev) {
    for (final fn in List<void Function(ConsumerSocketEvent)>.from(
      _globalListeners,
    )) {
      try {
        fn(ev);
      } catch (e, st) {
        log('[RealtimeHub] global listener error', error: e, stackTrace: st);
      }
    }
  }

  void _joinOrder(String orderId) {
    _joinedOrders.add(orderId);
    if (_socket?.connected == true) {
      _emitJoin(orderId);
    }
  }

  void _emitJoin(String orderId) {
    try {
      _socket?.emitWithAck('join-order-tracking', orderId, ack: (dynamic ack) {
        log('[RealtimeHub] join ack $orderId => $ack');
      });
    } catch (e, st) {
      log('[RealtimeHub] join emit failed', error: e, stackTrace: st);
    }
  }

  void _leaveOrder(String orderId) {
    _joinedOrders.remove(orderId);
    _lastDedupe.remove(orderId);
    try {
      _socket?.emit('leave-order-tracking', orderId);
    } catch (_) {
      /* ignore */
    }
  }

  Future<void> disconnect() async {
    clearPollingFallback();
    List<String>.from(_joinedOrders).forEach(_leaveOrder);
    _socket?.dispose();
    _socket = null;
  }
}
