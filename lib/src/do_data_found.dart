import 'package:flutter/material.dart';

class PageNotAvailableScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Page Not Available")),
      body: const Center(child: Text("This page is not available.")),
    );
  }
}
