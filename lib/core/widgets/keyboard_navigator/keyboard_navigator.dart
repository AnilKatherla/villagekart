import 'package:flutter/material.dart';

class KeyboardNavigator extends StatefulWidget {
  final Widget child;

  const KeyboardNavigator({super.key, required this.child});

  @override
  State<KeyboardNavigator> createState() => _KeyboardNavigatorState();
}

class _KeyboardNavigatorState extends State<KeyboardNavigator> {
  final List<FocusNode> focusNodes = [];
  bool _nodesCollected = false;

  void _collectFocusNodes() {
    focusNodes.clear();

    void findNodes(Element element) {
      if (element.widget is Focus) {
        final focusWidget = element.widget as Focus;
        if (focusWidget.focusNode != null &&
            focusWidget.canRequestFocus) {
          focusNodes.add(focusWidget.focusNode!);
        }
      }
      element.visitChildElements(findNodes);
    }

    context.visitChildElements(findNodes);
    _nodesCollected = true;
  }

  FocusNode? _currentFocus() {
    for (final node in focusNodes) {
      if (node.hasFocus) return node;
    }
    return null;
  }

  void _next() {
    final current = _currentFocus();
    if (current == null) return;

    final index = focusNodes.indexOf(current);
    if (index < focusNodes.length - 1) {
      FocusScope.of(context).requestFocus(focusNodes[index + 1]);
    }
  }

  void _previous() {
    final current = _currentFocus();
    if (current == null) return;

    final index = focusNodes.indexOf(current);
    if (index > 0) {
      FocusScope.of(context).requestFocus(focusNodes[index - 1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // 🔥 Collect focus nodes ONLY when keyboard opens
    if (keyboardHeight > 0 && !_nodesCollected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _collectFocusNodes();
      });
    }

    // Reset when keyboard closes
    if (keyboardHeight == 0) {
      _nodesCollected = false;
      focusNodes.clear();
    }

    return Stack(
      children: [
        widget.child,
        AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.only(bottom: keyboardHeight),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: keyboardHeight > 0
                ? _buildToolbar()
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      height: 45,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.black12,
        border: Border(top: BorderSide(color: Colors.black38)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_upward),
            onPressed: _previous,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_downward),
            onPressed: _next,
          ),
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () => FocusScope.of(context).unfocus(),
          ),
        ],
      ),
    );
  }
}
