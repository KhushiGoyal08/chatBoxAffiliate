import 'dart:convert';
import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  void requestNotificationPermission() async {
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      sound: true,
      provisional: true,
      carPlay: true,
      criticalAlert: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("USer granted Permission");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("USer granted Provisional Permission");
    } else {
      // AppSettings.openAppSettings(type: AppSettingsType.notification);
      print('User Denied Permission');
    }
  }

  Future sendNotification(String token, String title, String body,
      String recieverid, String chatRoomId) async {
    try {
      await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':
                'key=AAAAjIdKbm0:APA91bEIgOyA1a2NtPuhxDnNFNNl-_-IN3-Qhy1pE5Spim9F8cFpJ1d5r_K9VJW9AUrnXoWLTLDYoTEp8Gs2Q7zeVB5L14iGf7LrBUsp3cWcCEVk7TgHGz99b5wKVVc_ivAqtHULXFoM'
          },
          body: jsonEncode(
            <String, dynamic>{
              'priority': 'high',
              'data': <String, dynamic>{
                'click_action': "omd_click",
                'body': body,
                'title': title,
                'chatroomid': chatRoomId,
                'reciverid': recieverid,
              },
              "notification": <String, dynamic>{
                'title': title,
                'body': body,
                'android_channel_id': 'omd',
              },
              "to": token
            },
          ));
    } catch (e) {
      print(e);
    }
  }

  Future sendNotificationToAdmin(String token, String title, String body,
      String recieverid, String chatRoomId) async {
    try {
      await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':
                'key=AAAAjIdKbm0:APA91bEIgOyA1a2NtPuhxDnNFNNl-_-IN3-Qhy1pE5Spim9F8cFpJ1d5r_K9VJW9AUrnXoWLTLDYoTEp8Gs2Q7zeVB5L14iGf7LrBUsp3cWcCEVk7TgHGz99b5wKVVc_ivAqtHULXFoM'
          },
          body: jsonEncode(
            <String, dynamic>{
              'priority': 'high',
              'data': <String, dynamic>{
                'click_action': "admin_click",
                'body': body,
                'title': title,
                'chatroomid': chatRoomId,
                'reciverid': recieverid,
              },
              "notification": <String, dynamic>{
                'title': title,
                'body': body,
                'android_channel_id': 'omd',
              },
              "to": token
            },
          ));
    } catch (e) {
      print(e);
    }
  }

  Future sendNotificationAdminToUser(String token, String title, String body,
      String recieverid, String chatRoomId) async {
    try {
      await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':
                'key=AAAAjIdKbm0:APA91bEIgOyA1a2NtPuhxDnNFNNl-_-IN3-Qhy1pE5Spim9F8cFpJ1d5r_K9VJW9AUrnXoWLTLDYoTEp8Gs2Q7zeVB5L14iGf7LrBUsp3cWcCEVk7TgHGz99b5wKVVc_ivAqtHULXFoM'
          },
          body: jsonEncode(
            <String, dynamic>{
              'priority': 'high',
              'data': <String, dynamic>{
                'click_action': "user_click",
                'body': body,
                'title': title,
                'chatroomid': chatRoomId,
                'reciverid': recieverid,
              },
              "notification": <String, dynamic>{
                'title': title,
                'body': body,
                'android_channel_id': 'omd',
              },
              "to": token
            },
          ));
    } catch (e) {
      print(e);
    }
  }
}
