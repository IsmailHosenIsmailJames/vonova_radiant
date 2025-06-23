import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:vonova_radiant/src/app_css.dart';
import 'package:vonova_radiant/src/do_data_found.dart';
import 'package:vonova_radiant/src/no_internet.dart';

import 'core/in_app_update/in_app_android_update/in_app_update_android.dart';

class WebViewInApp extends StatefulWidget {
  const WebViewInApp({super.key});

  @override
  WebViewInAppState createState() => WebViewInAppState();
}

class WebViewInAppState extends State<WebViewInApp> {
  final GlobalKey _webViewKey = GlobalKey();
  InAppWebViewController? _webViewController;

  static const String _initialUrl = "http://103.168.140.134:5004/";

  final InAppWebViewSettings _webViewSettings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    cacheMode: CacheMode.LOAD_CACHE_ELSE_NETWORK,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: "camera; microphone",
    iframeAllowFullscreen: true,
  );

  PullToRefreshController? _pullToRefreshController;
  late ContextMenu _contextMenu;
  double _progress = 0;
  Widget _webViewWidget = const Center(
    child: CircularProgressIndicator(),
  ); // Renamed and initialized

  @override
  void initState() {
    super.initState();
    inAppUpdateAndroid(
      context,
    ); // Consider if this needs to be awaited or handled differently
    _initializeContextMenu();
    _initializePullToRefreshController();
    _initializeWebView();
  }

  void _initializeContextMenu() {
    _contextMenu = ContextMenu(
      menuItems: [
        ContextMenuItem(
          id: 1,
          title:
              "Special", // Consider a more descriptive title or make it a constant
          action: () async {
            await _webViewController?.clearFocus();
          },
        ),
      ],
      settings: ContextMenuSettings(hideDefaultSystemContextMenuItems: false),
      onCreateContextMenu: (hitTestResult) async {
        // Handle context menu creation if needed
      },
    );
  }

  void _initializePullToRefreshController() {
    if (kIsWeb ||
        ![
          TargetPlatform.iOS,
          TargetPlatform.android,
        ].contains(defaultTargetPlatform)) {
      _pullToRefreshController = null;
    } else {
      _pullToRefreshController = PullToRefreshController(
        settings: PullToRefreshSettings(color: Colors.blue),
        onRefresh: _attemptReload,
      );
    }
  }

  void _initializeWebView() {
    setState(() {
      _webViewWidget = _buildInAppWebView();
    });
  }

  Widget _buildInAppWebView() {
    return InAppWebView(
      key: _webViewKey,
      initialUrlRequest: URLRequest(url: WebUri(_initialUrl)),
      initialSettings: _webViewSettings,
      contextMenu: _contextMenu,
      pullToRefreshController: _pullToRefreshController,
      onWebViewCreated: (controller) {
        _webViewController = controller;
      },
      initialUserScripts: UnmodifiableListView<UserScript>([
        UserScript(
          source:
              """
      var style = document.createElement('style');
      style.id = 'flutter-injected-style';
      style.innerHTML = `$appCSS`;
      
      // Remove the old style if it already exists
      var oldStyle = document.getElementById('flutter-injected-style');
      if (oldStyle) {
        oldStyle.remove();
      }
      
      document.head.appendChild(style);
    """,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
        ),
        UserScript(
          source:
          """
      var style = document.createElement('style');
      style.id = 'flutter-injected-style';
      style.innerHTML = `$appCSS`;
      
      // Remove the old style if it already exists
      var oldStyle = document.getElementById('flutter-injected-style');
      if (oldStyle) {
        oldStyle.remove();
      }
      
      document.head.appendChild(style);
    """,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
        ),
      ]),
      onPermissionRequest: (controller, request) async {
        return PermissionResponse(
          resources: request.resources,
          action: PermissionResponseAction.GRANT,
        );
      },
      onReceivedError: (controller, request, error) {
        _pullToRefreshController?.endRefreshing();
        _handleLoadError();
      },
      onProgressChanged: (controller, progress) {
        if (progress == 100) {
          _pullToRefreshController?.endRefreshing();
        }
        setState(() {
          _progress = progress / 100;
        });
      },
    );
  }

  Future<bool> _isInternetAvailable() async {
    return await InternetConnection().internetStatus ==
        InternetStatus.connected;
  }

  Future<void> _navigateToErrorScreen(Widget errorScreen) async {
    if (mounted) {
      // Check if the widget is still in the tree
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => errorScreen),
      );
    }
  }

  Future<void> _attemptReload() async {
    if (_webViewController == null) return;

    if (defaultTargetPlatform == TargetPlatform.android) {
      await _webViewController?.reload();
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      final currentUrl = await _webViewController?.getUrl();
      if (currentUrl != null) {
        await _webViewController?.loadUrl(
          urlRequest: URLRequest(url: currentUrl),
        );
      }
    }
  }

  void _handleLoadError() async {
    bool hasInternet = await _isInternetAvailable();
    if (!hasInternet) {
      await _navigateToErrorScreen(InternetConnectionOffNotify());
    } else {
      await _navigateToErrorScreen(PageNotAvailableScreen());
    }
    // Attempt to reload regardless of the error type after showing the error screen
    // This allows the user to potentially get back to the webview if the issue was temporary
    await _attemptReload();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (await _webViewController?.canGoBack() ?? false) {
          _webViewController?.goBack();
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.blue, // Consider making this theme-dependent
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: [
                    _webViewWidget,
                    if (_progress < 1.0)
                      LinearProgressIndicator(value: _progress),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
