import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omd/controller/termsAndConditionController.dart';
import 'package:url_launcher/url_launcher.dart';
import '../home.dart';
import '../services/notification_service.dart';
import '../sign_ups.dart';
import '../widgets/button.dart';

class PermissionGuestUser extends StatelessWidget {
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
   builder: (context,orientation){
     return  SizedBox(
       height: (orientation ==Orientation.portrait)?MediaQuery.of(context).size.height*0.3 : 10,
     );
   },
  ),

            Button(
              icon: Icon(Icons.face, color: Color.fromRGBO(255, 255, 255, 1)),
              onPressed: () => Get.offAll(() => Home_Screen()),
              text: 'Guest User',
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height*0.05,
                top: 20,
              ),
              child: Button(
                icon: Icon(Icons.account_circle, color: Color.fromRGBO(255, 255, 255, 1)),
                onPressed: (){


                  Get.offAll(()=>Sign_Up());
                },
                text: 'Sign Up',
              ),
            )
          ],
        ),
      ),
    );
  }
}
