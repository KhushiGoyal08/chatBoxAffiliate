import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omd/drawer_navigation.dart';
import 'package:omd/home.dart';
import 'package:omd/pages/guestUserScreen.dart';
import 'package:omd/services/api_service.dart';

import 'package:omd/sign_ups.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'controller/termsAndConditionController.dart';
import 'login.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  String? sessionToken;
  String? currentUserId;
  bool? isContactVerified;
  String? jwttoken;
  // TermAndConditionController termcontroller =Get.put(TermAndConditionController());
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> getSessionToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    sessionToken = prefs.getString('sessionExpiration');
    jwttoken = prefs.getString('jwttoken') ?? '';
    currentUserId = prefs.getString('userId') ?? '';
    isContactVerified = prefs.getBool('iscontactverified');
    String? token = await _firebaseMessaging.getToken();
    print(token);
    print('JWTToken.........${jwttoken}');
    print('CurrentUser.........${currentUserId}');

    setState(() {});
  }

  Future<void> verifyUserToken() async {
    Future.delayed(Duration(seconds: 3), () async {
      ApiService apiService = ApiService();

      Map<String, dynamic> result =
      await apiService.verifyUserToken(currentUserId!, jwttoken!);

      if (result['success']) {
        // User is verified, navigate to HomeScreen
        Get.offAll(() => Home_Screen());
        print("Result..... ${result}");
      } else {
        // termcontroller.showTermsConditionsDialog();
        // User is not verified, navigate to SignUpScreen
        // Get.offAll(()  =>  Sign_Up());
        Get.offAll(() => PermissionGuestUser());
        print("Result..... ${result}");
      }
    });
  }

  void initState() {
    // TODO: implement initState
    super.initState();

    getSessionToken();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      verifyUserToken();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff5e879d),
      body: Center(
        child: Image(
          image: AssetImage('assets/splash_logo.jpg'),
          fit: BoxFit.cover,
        ), // Replace with your image path
      ),
    );
  }
}
