import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plain_notification_token/plain_notification_token.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _pushToken = 'Unknown';
  IosNotificationSettings? _settings;

  late StreamSubscription onTokenRefreshSubscription;
  late StreamSubscription onIosSubscription;

  @override
  void initState() {
    super.initState();

    onTokenRefreshSubscription = PlainNotificationToken().onTokenRefresh.listen((token) {
      setState(() {
        _pushToken = token;
      });
    });
    onIosSubscription = PlainNotificationToken().onIosSettingsRegistered.listen((settings) {
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
              Text("settings: $_settings"),
              Builder(
                builder: (context) => ElevatedButton(
                  child: Text("Request permission"),
                  onPressed: () {
                    PlainNotificationToken().requestPermission();
                  },
                ),
              )
            ],
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () async {
                  late String? token;
                  // Platform messages may fail, so we use a try/catch PlatformException.
                  try {
                    token = await PlainNotificationToken().getToken();
                  } on PlatformException {
                    token = 'Failed to get platform version.';
                  }
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(token ?? "(no token yet)")));
                },
              ),
        ),
      ),
    );
  }
}
