import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:villag_kart/core/realtime/consumer_realtime_hub.dart';

/// Reconnects the consumer Socket.IO client when the app returns to foreground.
class RealtimeResumeBinding extends StatefulWidget {
  const RealtimeResumeBinding({super.key, required this.child});

  final Widget child;

  @override
  State<RealtimeResumeBinding> createState() => _RealtimeResumeBindingState();
}

class _RealtimeResumeBindingState extends State<RealtimeResumeBinding>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ConsumerRealtimeHub.instance.ensureConnected());
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
