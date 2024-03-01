import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../home.dart';
import '../services/notification_service.dart';
import '../sign_ups.dart';
import '../widgets/button.dart';

class PermissionGuestUser extends StatelessWidget {
  final NotificationService notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Image(
              image: AssetImage('assets/logo-black.png'),
              fit: BoxFit.cover,
            ),
            Spacer(),
            Button(
              icon: Icon(Icons.face, color: Color.fromRGBO(255, 255, 255, 1)),
              onPressed: () => _handleButtonClick(Home_Screen()),
              text: 'Guest User',
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.1,
                top: 20,
              ),
              child: Button(
                icon: Icon(Icons.account_circle, color: Color.fromRGBO(255, 255, 255, 1)),
                onPressed: (){
                  showDialog(context: context, builder: (BuildContext context){
                    return  Dialog(

                      backgroundColor: Colors.white,
                      child: Container(
                        height: MediaQuery.of(context).size.height*0.6,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                            children: [
                              Text('Terms and \n conditions update',textAlign:TextAlign.center,style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Montserrat',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold
                              ),),
                              Image(image: AssetImage('assets/termsandcondition.png'),width: MediaQuery.of(context).size.width*0.4,),
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
                                    TextSpan(text: ' have been recently updated . To continue using our app , please review and agree to our updated terms. '),
                                  ],
                                ),
                              ),
                              Button(onPressed: (){
                                _handleButtonClick(Sign_Up());
                              }, icon: Icon(Icons.check_circle,color: Colors.white,), text: "Yes,I agree")
                            ],
                          ),
                        ),
                      ),
                    );
                  });
                  // _handleButtonClick(Sign_Up());
                },
                text: 'Sign Up',
              ),
            )
          ],
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

