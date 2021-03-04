import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plain_notification_token/plain_notification_token.dart';

void main() {
  const MethodChannel channel = MethodChannel('plain_notification_token');
  WidgetsFlutterBinding.ensureInitialized();

  group("PlainNotificationToken", () {
    group("In Android", () {
      final String fcmToken = "jfhwe9hopw:klNGbipbihigIGigighigIGrdUIOgh86VuOi";

      setUp(() {
        channel.setMockMethodCallHandler((MethodCall methodCall) async {
          switch (methodCall.method) {
            case "getToken":
              return fcmToken;
          }
        });
      });

      tearDown(() {
        channel.setMockMethodCallHandler(null);
      });

      test("can get token", () async {
        final pnt = PlainNotificationToken();
        final actual = await pnt.getToken();
        expect(actual, equals(fcmToken));
      });
    });

    group("In iOS", () {
      final String apnsToken = "89369abc76a0e86fa60c75d64a52b696629d766f070ba6";

      setUp(() {
        channel.setMockMethodCallHandler((MethodCall methodCall) async {
          switch (methodCall.method) {
            case "getToken":
              return apnsToken;
          }
        });
      });

      tearDown(() {
        channel.setMockMethodCallHandler(null);
      });

      test("can get token", () async {
        final pnt = PlainNotificationToken();
        final actual = await pnt.getToken();
        expect(actual, equals(apnsToken));
      });
    });
  });

  group("IosNotificationSettings", () {
    test("can serialize to map", () {
      final from =
          IosNotificationSettings(alert: true, badge: true, sound: false);
      expect(
          from.toMap(),
          equals({
            "alert": true,
            "badge": true,
            "sound": false,
          }));
    });
  });
}
