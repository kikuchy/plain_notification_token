#import "PlainNotificationTokenPlugin.h"
#import <UserNotifications/UserNotifications.h>

@implementation PlainNotificationTokenPlugin {
    NSString *_lastToken;
    FlutterMethodChannel *_channel;
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"plain_notification_token"
            binaryMessenger:[registrar messenger]];
  PlainNotificationTokenPlugin* instance = [[PlainNotificationTokenPlugin alloc] initWithChannel:channel];
  [registrar addApplicationDelegate:instance];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
    self = [super init];
    
    if (self) {
        _channel = channel;
        dispatch_async(dispatch_get_main_queue(), ^() {
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        });
        if (@available(iOS 10.0, *)) {
            [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                NSDictionary *settingsDictionary = @{
                                                     @"sound" : [NSNumber numberWithBool:settings.soundSetting == UNNotificationSettingEnabled],
                                                     @"badge" : [NSNumber numberWithBool:settings.badgeSetting == UNNotificationSettingEnabled],
                                                     @"alert" : [NSNumber numberWithBool:settings.alertSetting == UNNotificationSettingEnabled],
                                                     };
                [self->_channel invokeMethod:@"onIosSettingsRegistered" arguments:settingsDictionary];
            }];
        }
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getToken" isEqualToString:call.method]) {
    result([self getToken]);
  } else if ([@"requestPermission" isEqualToString:call.method]) {
      [self requestPermissionWithSettings:[call arguments]];
      result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (NSString *)getToken {
    return _lastToken;
}

- (void)requestPermissionWithSettings: (NSDictionary<NSString*, NSNumber*> *)settings {
    if (@available(iOS 10.0, *)) {
        UNAuthorizationOptions options = UNAuthorizationOptionNone;
        if ([[settings objectForKey:@"sound"] boolValue]) {
            options |= UNAuthorizationOptionSound;
        }
        if ([[settings objectForKey:@"badge"] boolValue]) {
            options |= UNAuthorizationOptionBadge;
        }
        if ([[settings objectForKey:@"alert"] boolValue]) {
            options |= UNAuthorizationOptionAlert;
        }
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Error during requesting notification permission: %@", error);
            }
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^() {
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
                [self->_channel invokeMethod:@"onIosSettingsRegistered" arguments:settings];
            } else {
                NSNumber* falseNumber = [NSNumber numberWithBool: NO];
                NSDictionary<NSString*, NSNumber*> *empty = [NSDictionary dictionaryWithObjectsAndKeys: falseNumber, @"badge", falseNumber, @"alert", falseNumber, @"sound", nil];
                [self->_channel invokeMethod:@"onIosSettingsRegistered" arguments:empty];
            }
        }];
    }
    else {
        UIUserNotificationType types = 0;
        if ([[settings objectForKey:@"sound"] boolValue]) {
            types |= UIUserNotificationTypeSound;
        }
        if ([[settings objectForKey:@"badge"] boolValue]) {
            types |= UIUserNotificationTypeBadge;
        }
        if ([[settings objectForKey:@"alert"] boolValue]) {
            types |= UIUserNotificationTypeAlert;
        }
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
}

#pragma mark - AppDelegate

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    NSDictionary *settingsDictionary = @{
                                         @"sound" : [NSNumber numberWithBool:notificationSettings.types & UIUserNotificationTypeSound],
                                         @"badge" : [NSNumber numberWithBool:notificationSettings.types & UIUserNotificationTypeBadge],
                                         @"alert" : [NSNumber numberWithBool:notificationSettings.types & UIUserNotificationTypeAlert],
                                         };
    [_channel invokeMethod:@"onIosSettingsRegistered" arguments:settingsDictionary];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    const char *data = [deviceToken bytes];
    NSMutableString *ret = [NSMutableString string];
    for (NSUInteger i = 0; i < [deviceToken length]; i++) {
        [ret appendFormat:@"%02.2hhx", data[i]];
    }
    _lastToken = [ret copy];
    [_channel invokeMethod:@"onToken" arguments:_lastToken];
}

@end
