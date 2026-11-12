import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:plain_notification_token/plain_notification_token.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _pushToken = 'Unknown';
  IosNotificationSettings? _settings;

  late StreamSubscription onTokenRefreshSubscription;
  late StreamSubscription onIosSubscription;

  @override
  void initState() {
    super.initState();

    onTokenRefreshSubscription = ApnsToken().onTokenRefresh.listen((token) {
      setState(() {
        _pushToken = token;
      });
    });
    onIosSubscription = ApnsToken().onIosSettingsRegistered.listen((settings) {
      setState(() {
        _settings = settings;
      });
    });
  }

  @override
  void dispose() {
    onTokenRefreshSubscription.cancel();
    onIosSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Text('token: $_pushToken\n'),
              Text('settings: $_settings'),
              Builder(
                builder: (context) => ElevatedButton(
                  child: const Text('Request permission'),
                  onPressed: () {
                    ApnsToken().requestPermission();
                  },
                ),
              )
            ],
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
                child: const Icon(Icons.search),
                onPressed: () async {
                  late String? token;
                  // Platform messages may fail, so we use a try/catch PlatformException.
                  try {
                    token = await ApnsToken().getToken();
                  } on PlatformException {
                    token = 'Failed to get platform version.';
                  }
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(token ?? '(no token yet)')));
                },
              ),
        ),
      ),
    );
  }
}
