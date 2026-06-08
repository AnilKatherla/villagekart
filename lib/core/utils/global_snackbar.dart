import 'package:flutter/material.dart';

enum SnackPosition { top, bottom }

class GlobalSnackbar {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void show(
  String title,
  String message, {
  bool isError = false,
  SnackPosition position = SnackPosition.bottom,
}) {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  if (position == SnackPosition.bottom) {
    _showBottom(context, title, message, isError);
  } else {
    _showTop(message, isError); // ✅ FIXED
  }
}

  // 🔽 Bottom (default Flutter SnackBar)
  static void _showBottom(
      BuildContext context, String title, String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(message),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

 static void _showTop(
  String message,
  bool isError,
) {
  final overlay = navigatorKey.currentState?.overlay;

  if (overlay == null) return;

  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isError ? Colors.red : Colors.green,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                isError ? Icons.error : Icons.check_circle,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  // ✅ instant render (no delay)
  WidgetsBinding.instance.addPostFrameCallback((_) {
    overlay.insert(entry);
  });

  Future.delayed(const Duration(seconds: 3), () {
    if (entry.mounted) entry.remove();
  });
}
}