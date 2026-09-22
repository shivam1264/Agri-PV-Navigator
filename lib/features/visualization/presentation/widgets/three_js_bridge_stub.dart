import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ThreeJsBridge extends StatefulWidget {
  final String configJson;

  const ThreeJsBridge({super.key, required this.configJson});

  @override
  State<ThreeJsBridge> createState() => _ThreeJsBridgeState();
}

class _ThreeJsBridgeState extends State<ThreeJsBridge> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setOnConsoleMessage((message) {
        debugPrint("ThreeJS WebView Console [${message.level}]: ${message.message}");
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              // Once loaded, inject the initial config
              _updateScene(widget.configJson);
            }
          },
          onWebResourceError: (error) {
            debugPrint("ThreeJS WebView Error: ${error.description}");
          },
        ),
      );
    
    _loadHtml();
  }

  Future<void> _loadHtml() async {
    try {
      // Load the three_engine.js script from assets
      final threeEngineScript = await rootBundle.loadString('web/three_engine.js');
      
      // Construct the HTML document
      final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/controls/OrbitControls.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/objects/Sky.js"></script>
  <style>
    body { margin: 0; padding: 0; overflow: hidden; background-color: #87CEEB; }
    #three-container { width: 100vw; height: 100vh; }
  </style>
  <script>
    $threeEngineScript
  </script>
</head>
<body>
  <div id="three-container"></div>
  <script>
    // Initialize scene when document is ready
    window.onload = function() {
      if (window.initAgriPvScene) {
        window.initAgriPvScene('three-container');
      }
    };
  </script>
</body>
</html>
''';

      await _controller.loadHtmlString(htmlContent, baseUrl: 'https://localhost/');
    } catch (e) {
      debugPrint("Error loading ThreeJS HTML: \$e");
    }
  }

  @override
  void didUpdateWidget(covariant ThreeJsBridge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.configJson != widget.configJson) {
      _updateScene(widget.configJson);
    }
  }

  void _updateScene(String configJson) {
    if (!_isLoading) {
      // Escape the JSON string to safely pass it into JS execution
      final escapedJson = jsonEncode(configJson); 
      _controller.runJavaScript("if (window.updateAgriPvScene) { window.updateAgriPvScene($escapedJson); }");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
      ],
    );
  }
}
