import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetConnectionOffNotify extends StatefulWidget {
  const InternetConnectionOffNotify({super.key});

  @override
  State<InternetConnectionOffNotify> createState() =>
      _InternetConnectionOffNotifyState();
}

class _InternetConnectionOffNotifyState
    extends State<InternetConnectionOffNotify> {
  @override
  void initState() {
    InternetConnection().onStatusChange.listen((InternetStatus status) {
      log('status: $status');
      if (status == InternetStatus.connected) {
        Navigator.pop(context);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                height: 200,
                width: 200,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1000),
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.4),
                      Colors.blue.withOpacity(0.1),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: const Image(
                  image: AssetImage(
                    'assets/No_Internet_Connection.png',
                  ),
                ),
              ),
            ),
            const Gap(20),
            const Text(
              'No internet connection',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Gap(10),
            Text(
              'We must need internet connection for running this\napp with essential features. Please turn on\ninternet connection, then you can go next step.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const Gap(30),
          ],
        ),
      ),
    );
  }
}
