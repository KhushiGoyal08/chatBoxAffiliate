import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omd/home.dart';
import 'package:omd/signup.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/notification_service.dart';
import '../sign_ups.dart';

class TermAndConditionController extends GetxController {
  final NotificationService notificationService = NotificationService();
  void showTermsConditionsDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        child: Container(
          height: Get.height * 0.6,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Terms and \n conditions update',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Montserrat',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Image(
                  image: AssetImage('assets/termsandcondition.png'),
                  width: Get.width * 0.4,
                ),
                RichText(
                  text: TextSpan(
                    text: 'Our',
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: 'Terms and Conditions',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _launchURL('https://affiliatechatbox.com/terms.html');
                          },
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _launchURL('https://affiliatechatbox.com/Privacy-Policy.html');
                          },
                      ),
                      TextSpan(
                        text: ' have been recently updated. To continue using our app, please review and agree to our updated terms. ',
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff102E44),

                  ),
                  onPressed: () {
                    _handleButtonClick(Home_Screen());
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text("Yes, I agree",
                        style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 1),
                          fontFamily: 'Montserrat',
                          fontSize: 17,
                        ),),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleButtonClick(Widget page) {
    notificationService.requestNotificationPermission();
    Get.offAll(() => page);
  }


  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

}

