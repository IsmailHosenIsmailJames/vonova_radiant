import 'dart:collection';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:vonova_radiant/src/do_data_found.dart';
import 'package:vonova_radiant/src/no_internet.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'core/in_app_update/in_app_android_update/in_app_update_android.dart';

class WebViewInApp extends StatefulWidget {
  const WebViewInApp({super.key});

  @override
  WebViewInAppState createState() => WebViewInAppState();
}

class WebViewInAppState extends State<WebViewInApp> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    cacheMode: CacheMode.LOAD_CACHE_ELSE_NETWORK,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: "camera; microphone",
    iframeAllowFullscreen: true,
  );

  PullToRefreshController? pullToRefreshController;

  late ContextMenu contextMenu;
  double progress = 0;
  Widget initWidget = const Center(child: CircularProgressIndicator());

  void initLastWebUrl() async {
    String initUrl = "https://jenpharliveraid.com/";
    setState(() {
      initWidget = InAppWebView(
        key: webViewKey,
        // initialFile: initUrl,
        initialUrlRequest: URLRequest(url: WebUri(initUrl)),
        // initialUrlRequest:
        // URLRequest(url: WebUri(Uri.base.toString().replaceFirst("/#/", "/") + 'page.html')),
        // initialFile: "assets/index.html",
        initialUserScripts: UnmodifiableListView<UserScript>([]),
        initialSettings: settings,
        contextMenu: contextMenu,
        pullToRefreshController: pullToRefreshController,
        onWebViewCreated: (controller) async {
          webViewController = controller;
        },
        onLoadStart: (controller, url) async {},

        onPermissionRequest: (controller, request) async {
          return PermissionResponse(
            resources: request.resources,
            action: PermissionResponseAction.GRANT,
          );
        },

        onReceivedError: (controller, request, error) {
          pullToRefreshController?.endRefreshing();
          _handleLoadError();
        },
        onProgressChanged: (controller, progress) {
          if (progress == 100) {
            pullToRefreshController?.endRefreshing();
          }
          setState(() {
            this.progress = progress / 100;
          });
        },
      );
    });
  }

  Future<bool> _isInternetAvailable() async {
    return await InternetConnection().internetStatus ==
        InternetStatus.connected;
  }

  void _handleLoadError() async {
    bool hasInternet = await _isInternetAvailable();
    if (!hasInternet) {
      // No internet, navigate to error page
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => InternetConnectionOffNotify()),
      );
      if (defaultTargetPlatform == TargetPlatform.android) {
        webViewController?.reload();
      } else if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        webViewController?.loadUrl(
          urlRequest: URLRequest(url: await webViewController?.getUrl()),
        );
      }
    } else {
      // Internet available, but URL might not be cached
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PageNotAvailableScreen()),
      );
      if (defaultTargetPlatform == TargetPlatform.android) {
        webViewController?.reload();
      } else if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        webViewController?.loadUrl(
          urlRequest: URLRequest(url: await webViewController?.getUrl()),
        );
      }
    }
  }

  @override
  void initState() {
    FlutterNativeSplash.remove();
    inAppUpdateAndroid(context);

    super.initState();
    contextMenu = ContextMenu(
      menuItems: [
        ContextMenuItem(
          id: 1,
          title: "Special",
          action: () async {
            await webViewController?.clearFocus();
          },
        ),
      ],
      settings: ContextMenuSettings(hideDefaultSystemContextMenuItems: false),
      onCreateContextMenu: (hitTestResult) async {},
    );

    pullToRefreshController =
        kIsWeb ||
            ![
              TargetPlatform.iOS,
              TargetPlatform.android,
            ].contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(color: Colors.blue),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS) {
                webViewController?.loadUrl(
                  urlRequest: URLRequest(
                    url: await webViewController?.getUrl(),
                  ),
                );
              }
            },
          );

    initLastWebUrl();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        bool? canPop = await webViewController?.canGoBack();
        if (canPop == true) {
          webViewController?.goBack();
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.blue,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: [
                    initWidget,
                    progress < 1.0
                        ? LinearProgressIndicator(value: progress)
                        : Container(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> deleteFolder(Directory directory) async {
    if (await directory.exists()) {
      // List all entities inside the directory (files, subdirectories)
      final List<FileSystemEntity> entities = await directory.list().toList();

      // Iterate through the list of entities
      for (FileSystemEntity entity in entities) {
        if (entity is Directory) {
          // If the entity is a directory, call deleteFolder recursively
          await deleteFolder(entity);
        } else if (entity is File) {
          // If the entity is a file, delete it
          await entity.delete();
        }
      }

      // After deleting all contents, delete the directory itself
      await directory.delete();
    }
  }
}
