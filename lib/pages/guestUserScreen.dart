import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:omd/controller/termsAndConditionController.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';
import '../home.dart';
import '../services/notification_service.dart';
import '../sign_ups.dart';
import '../widgets/button.dart';

class PermissionGuestUser extends StatelessWidget {
  TermAndConditionController termAndConditionController =
      Get.put(TermAndConditionController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Image(
              image: AssetImage('assets/logo-black.png'),
              height: 300,
              width: 300,
            ),
            OrientationBuilder(
              builder: (context, orientation) {
                return SizedBox(
                  height: (orientation == Orientation.portrait)
                      ? MediaQuery.of(context).size.height * 0.3
                      : 10,
                );
              },
            ),
            Button(
              icon: Icon(Icons.face, color: Color.fromRGBO(255, 255, 255, 1)),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            UpgradeAlert(child: Home_Screen())),
                    (route) => false);

                termAndConditionController.showTermsConditionsDialog(context);
              },
              text: 'Guest User',
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.05,
                top: 20,
              ),
              child: Button(
                icon: Icon(Icons.account_circle,
                    color: Color.fromRGBO(255, 255, 255, 1)),
                onPressed: () {
                  Get.offAll(() => UpgradeAlert(child: Sign_Up()));
                },
                text: 'Sign Up / Login',
              ),
            )
          ],
        ),
      ),
    );
  }
}
