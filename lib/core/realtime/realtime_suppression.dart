/// Tracks recent socket-driven order activity so FCM foreground can avoid duplicate banners.
class RealtimeSuppression {
  RealtimeSuppression._();
  static final Map<String, int> _lastSocketMsByOrder = {};
  static const int _windowMs = 12000;

  static void touchOrder(String? orderId) {
    if (orderId == null || orderId.isEmpty) return;
    _lastSocketMsByOrder[orderId] = DateTime.now().millisecondsSinceEpoch;
    if (_lastSocketMsByOrder.length > 500) {
      final now = DateTime.now().millisecondsSinceEpoch;
      _lastSocketMsByOrder.removeWhere((_, t) => now - t > _windowMs * 4);
    }
  }

  static bool shouldSuppressFcmBannerForOrder(String? orderId) {
    if (orderId == null || orderId.isEmpty) return false;
    final t = _lastSocketMsByOrder[orderId];
    if (t == null) return false;
    return DateTime.now().millisecondsSinceEpoch - t < _windowMs;
  }
}
