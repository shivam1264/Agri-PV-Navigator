import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

bool _registered = false;

class ThreeJsBridge extends StatefulWidget {
  final String configJson;

  const ThreeJsBridge({super.key, required this.configJson});

  @override
  State<ThreeJsBridge> createState() => _ThreeJsBridgeState();
}

class _ThreeJsBridgeState extends State<ThreeJsBridge> {
  final String _viewType = 'three-js-view';

  @override
  void initState() {
    super.initState();
    if (!_registered) {
      ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
        final containerId = 'three-container-$viewId';
        final div = html.DivElement()
          ..id = containerId
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.border = 'none'
          ..style.outline = 'none'
          ..style.backgroundColor = 'transparent';

        // Initialize Three.js engine after the div is in DOM
        Future.delayed(const Duration(milliseconds: 150), () {
          if (html.document.getElementById(containerId) != null) {
            js.context.callMethod('initAgriPvScene', [containerId]);
            js.context.callMethod('updateAgriPvScene', [widget.configJson]);
          }
        });

        return div;
      });
      _registered = true;
    }
  }

  @override
  void didUpdateWidget(covariant ThreeJsBridge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.configJson != widget.configJson) {
      try {
        js.context.callMethod('updateAgriPvScene', [widget.configJson]);
      } catch (e) {
        debugPrint('Failed to update Three.js: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
