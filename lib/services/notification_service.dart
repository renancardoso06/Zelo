import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    // Solicita permissão de notificações
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Token do dispositivo (usado para enviar push segmentado)
    final token = await _messaging.getToken();
    debugPrint('FCM Token: $token');

    // Listener para mensagens com app em foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Notificação recebida: ${message.notification?.title}');
    });

    // Listener para quando o app é aberto via notificação
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('App aberto via notificação: ${message.data}');
    });
  }

  /// Simula o recebimento de uma notificação de alerta
  /// Em produção, isso viria do backend via FCM
  static Map<String, String> simulatedAlert() => {
        'title': '✅ Serviço confirmado!',
        'body': 'Maria Silva confirmou a faxina para amanhã às 9h.',
        'type': 'service_confirmed',
      };
}
