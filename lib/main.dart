import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omd/admin_chat_page.dart';
import 'package:omd/contact_admin.dart';
import 'package:omd/controller/bindings.dart';
import 'package:omd/provider/image_provider.dart';
import 'package:omd/splash.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:upgrader/upgrader.dart';
import 'chat.dart';

AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  _showNotification(message);

  //No need for showing Notification manually.
  //For BackgroundMessages: Firebase automatically sends a Notification.
  //If you call the flutterLocalNotificationsPlugin.show()-Methode for
  //example the Notification will be displayed twice.

  // await setupFlutterNotifications();
  // showFlutterNotification(message);
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  //print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.getInitialMessage();
  //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.initialize(const DarwinInitializationSettings());
  // FirebaseMessaging.onBackgroundMessage((RemoteMessage message) {
  //   if (message.notification != null) {
  //     //No need for showing Notification manually.
  //     //For BackgroundMessages: Firebase automatically sends a Notification.
  //     //If you call the flutterLocalNotificationsPlugin.show()-Methode for
  //     //example the Notification will be displayed twice.
  //   }

  // });
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  var androidInit =
      const AndroidInitializationSettings('@drawable/notification');

  var initSettings = InitializationSettings(android: androidInit);
  try {
    FirebaseMessaging _messaging = FirebaseMessaging.instance;

    String? token = await _messaging.getToken();
    print("The token is " + token!);

    await flutterLocalNotificationsPlugin.initialize(initSettings,
        onDidReceiveNotificationResponse: (payload) async {
      try {
        if (payload.payload != null && payload.payload!.isNotEmpty) {
          print(payload.payload.toString());
          Map<String, dynamic> data = jsonDecode(payload.payload!);
          if (data['click_action'] == "omd_click") {
            Get.to(() => ChatPage(
                chatRoomId: data['chatroomid'], receiverId: data['reciverid']));
          } else if (data['click_action'] == "admin_click") {
            Get.to(() => AdminChatPage(
                chatRoomId: data['chatroomid'], receiverId: data['reciverid']));
          } else if (data['click_action'] == "user_click") {
            Get.to(() => ContactAdmin(
                chatRoomId: data['chatroomid'], receiverId: data['reciverid']));
          }
        } else {}
      } catch (e) {
        //print(e);
      }
      return;
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("on message");
      print(message.data);

      _showNotification(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['click_action'] == 'omd_click') {
        Get.to(() => ChatPage(
            chatRoomId: message.data['chatroomid'],
            receiverId: message.data['reciverid']));
      } else if (message.data['click_action'] == "admin_click") {
        Get.to(() => AdminChatPage(
            chatRoomId: message.data['chatroomid'],
            receiverId: message.data['reciverid']));
      } else if (message.data['click_action'] == "user_click") {
        Get.to(() => ContactAdmin(
            chatRoomId: message.data['chatroomid'],
            receiverId: message.data['reciverid']));
      } else {}
      print('A new onMessageOpenedApp event was published!');

      // _showNotification(message);
    });
  } catch (e) {
    print(e.toString());
  }
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => ImageProviderClass()),
  ], child: const MyApp()));
}

Future<void> _showNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('Affiliate Chat Box', 'Affiliate Chat Box',
          channelDescription: 'Affiliate Chat Box App',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          ticker: 'ticker');

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  print("Simple");
  await flutterLocalNotificationsPlugin.show(0, message.notification!.title,
      message.notification!.body, notificationDetails,
      payload: jsonEncode(message.data));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // initialBinding: GetXBindings(),
      debugShowCheckedModeBanner: false,
      home: Splash(),
    );
  }
}
