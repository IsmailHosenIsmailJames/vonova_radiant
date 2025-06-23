import 'package:flutter/material.dart';
import 'package:vonova_radiant/src/web_view.dart';

bool isUpdateChecked = false;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      themeMode: ThemeMode.light,
      home: const WebViewInApp(),
    );
  }
}
