import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:my_games_list/core/data/services/http/i_http_client.dart';

/// Service that manages Firebase Cloud Messaging (FCM) integration.
///
/// Responsibilities:
/// - Requesting notification permissions
/// - Displaying foreground notifications via flutter_local_notifications
/// - Sending the FCM token to the backend for push delivery
/// - Emitting navigation events when a notification tap contains a route
class NotificationService {
  NotificationService({required IHttpClient httpClient})
      : _httpClient = httpClient;

  final IHttpClient _httpClient;
  // Accessed lazily so construction does not throw in test environments
  // where Firebase is not initialized.
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _navigationController = StreamController<String>.broadcast();
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSubscription;

  /// Stream of route strings to navigate to when a notification is tapped.
  Stream<String> get navigationStream => _navigationController.stream;

  Future<void> initialize() async {
    // 1. Request permissions
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Initialize flutter_local_notifications for foreground display
    await _initLocalNotifications();

    // 3. Get FCM token and send to backend
    final token = await _messaging.getToken();
    if (token != null) await _sendTokenToBackend(token);

    // 4. Listen for token refreshes
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(
      _sendTokenToBackend,
    );

    // 5. Foreground message handler (show local notification)
    _onMessageSubscription = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );

    // 6. Notification tap: app was in background, user tapped notification
    _onMessageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleNotificationTap,
    );

    // 7. Notification tap: app was terminated, opened from notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) _handleNotificationTap(initialMessage);
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          _navigationController.add(details.payload!);
        }
      },
    );
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'Default',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: message.data['route'] as String?,
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    final route = message.data['route'];
    if (route != null && (route as String).isNotEmpty) {
      _navigationController.add(route);
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      String platform = 'android';
      if (kIsWeb) {
        platform = 'web';
      } else if (Platform.isIOS) {
        platform = 'ios';
      }
      await _httpClient.patch(
        '/users/me/fcm-token',
        data: {'fcm_token': token, 'platform': platform},
      );
    } catch (_) {
      // Non-critical: silently ignore failures
    }
  }

  void dispose() {
    _tokenRefreshSubscription?.cancel();
    _onMessageSubscription?.cancel();
    _onMessageOpenedAppSubscription?.cancel();
    _navigationController.close();
  }
}
