import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omd/home.dart';
import 'package:omd/services/api_service.dart';
import 'package:omd/sign_ups.dart';
import 'package:omd/signup.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

import 'package:omd/widgets/utils.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'controller/termsAndConditionController.dart';

class Verify_OTP extends StatefulWidget {
  final String phoneNumber;
  final String countryFlag;
  final bool verify;
  bool isSuspended;
  bool isEmailVerified;
  Verify_OTP(
      {Key? key,
      required this.phoneNumber,
      required this.countryFlag,
      this.isSuspended = false,
      this.isEmailVerified = false,
      required this.verify})
      : super(key: key);

  @override
  State<Verify_OTP> createState() => _Verify_OTPState();
}

class _Verify_OTPState extends State<Verify_OTP> with TickerProviderStateMixin {
  FirebaseAuth auth = FirebaseAuth.instance;
  bool isLoading = false;
  String? token;
  bool? isEmailVerified;
  TermAndConditionController termcontroller =
      Get.put(TermAndConditionController());
  Future<void> _saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', '');
    prefs.setString('token', token);
    print("Token......././././././././../ ${token} is saved successfully");
  }

  Future<void> _saveUserDataInSharedPreferences(
      Map<String, dynamic>? userData) async {
    if (userData != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString('userId', userData['_id'] ?? '');
      prefs.setString('firstName', userData['firstName'] ?? '');
      prefs.setString('lastName', userData['lastName'] ?? '');
      prefs.setString('email', userData['email'] ?? '');
      prefs.setString('mobileNumber', userData['mobileNumber'] ?? '');
      prefs.setString('profileImageUrl', userData['profileImageUrl'] ?? '');
      prefs.setString('AboutMe', userData['AboutMe'] ?? '');
      prefs.setString('Company', userData['Company'] ?? '');
      prefs.setString('Designation', userData['Designation'] ?? '');
      prefs.setString('Facebook', userData['Facebook'] ?? '');
      prefs.setString('Instagram', userData['Instagram'] ?? '');
      prefs.setString('LinkedIn', userData['LinkedIn'] ?? '');
      prefs.setString('Skype', userData['Skype'] ?? '');
      prefs.setString('Telegram', userData['Telegram'] ?? '');
      prefs.setString('jwttoken', userData['jwttoken'] ?? '');
      prefs.setBool('iscontactverified', userData['iscontactverified']);
      prefs.setString('sessionExpiration', userData['sessionExpiration'] ?? '');
      prefs.setString('token', userData['token'] ?? '');
      prefs.setBool('isSuspended', widget.isSuspended!);
      prefs.setBool('isEmailVerified', widget.isEmailVerified);

      print("User data saved in SharedPreferences");
    } else {
      print("userData is null");
    }
  }

  final _firebaseMessaging = FirebaseMessaging.instance;

  Future getToken() async {
    token = await _firebaseMessaging.getToken();
    setState(() {});
  }

  OtpFieldController otpbox = OtpFieldController();

  String _verificationId = "";
  int? _resendToken;
  bool isResend = false;
  String otp = '';
  Future<bool> sendOTP({required String phone}) async {
    setState(() {
      isResend = true;
    });
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {},
        codeSent: (String verificationId, int? resendToken) async {
          _verificationId = verificationId;
          _resendToken = resendToken;
        },
        timeout: const Duration(seconds: 25),
        forceResendingToken: _resendToken,
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationId = _verificationId;
        },
      );
      debugPrint("_verificationId: $_verificationId");
      setState(() {
        isResend = false;
      });
      return true;
    } catch (e) {
      setState(() {
        isResend = false;
      });
      print(e.toString());
      return false;
    }
  }

  var code;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    getToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: !isResend
            ? Center(
                child: Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/logo-black.png',
                          height: 300,
                          width: 300,
                        ),

                        const Text(
                          'OTP Verification',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Color.fromRGBO(91, 91, 91, 1),
                              fontFamily: 'Montserrat',
                              fontSize: 24,
                              letterSpacing: 0,
                              fontWeight: FontWeight.w700,
                              height: 1),
                        ),
                        const SizedBox(
                          height: 20,
                        ),

                        const Text(
                          'We will send you one-time password',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color.fromRGBO(58, 58, 58, 1),
                              fontFamily: 'Montserrat',
                              fontSize: 15,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.w400,
                              height: 1.5000000298979959),
                        ),
                        const Text(
                          'to you mobile number',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color.fromRGBO(58, 58, 58, 1),
                              fontFamily: 'Montserrat',
                              fontSize: 15,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.w400,
                              height: 1.5000000298979959),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: OTPTextField(
                            outlineBorderRadius: 10,
                            controller: otpbox,
                            length: 6,
                            width: MediaQuery.of(context).size.width,
                            fieldWidth: 30,
                            style: TextStyle(fontSize: 17),
                            textFieldAlignment: MainAxisAlignment.spaceAround,
                            fieldStyle: FieldStyle.box,
                            onCompleted: (pin) {
                              code = pin;
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 14,
                            ),
                            const Text(
                              'Didn’t you receive the OTP yet?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xffB9B9B9),
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
                                  letterSpacing:
                                      0 /*percentages not used in flutter. defaulting to zero*/,
                                  fontWeight: FontWeight.normal,
                                  height: 1.5000000298979959),
                            ),
                            GestureDetector(
                              onTap: () {
                                sendOTP(phone: widget.phoneNumber);
                                Utils().toastMessage(
                                    context,
                                    "Request Sent Please Wait...",
                                    Colors.black54);
                              },
                              child: Text(
                                ' Resend OTP',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(0xff102E44),
                                    fontFamily: 'Montserrat',
                                    fontSize: 12,
                                    letterSpacing:
                                        0 /*percentages not used in flutter. defaulting to zero*/,
                                    fontWeight: FontWeight.normal,
                                    height: 1.5000000298979959),
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'or reach out to us on contactus@affiliatechatbox.com',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color(0xffB9B9B9),
                              fontFamily: 'Montserrat',
                              fontSize: 15,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.normal,
                              height: 1.5000000298979959),
                        ),
                        const SizedBox(height: 30),
                        // Figma Flutter Generator Rectangle1Widget - RECTANGLE
                        GestureDetector(
                          onTap: () async {
                            setState(() {
                              isLoading = true;
                            });
                            final credential = PhoneAuthProvider.credential(
                                verificationId: Sign_Up.verify, smsCode: code);

                            // Sign the user in (or link) with the credential
                            try {
                              await auth.signInWithCredential(credential);
                              final result = await ApiService()
                                  .verifyUser(widget.phoneNumber);
                              print(result);
                              if (result['success']) {
                                final userData = result['data']['user'];
                                print("UserData.........${userData}");
                                final userId = userData['_id'];
                                final userMobileNumber =
                                    userData['mobileNumber'];

                                print(result['data']);
                                print('......................${userId}');
                                print(
                                    '................${userData['jwttoken']}');
                                _saveUserDataInSharedPreferences(userData);
                                print("token: ${token}");

                                final tokenResult = await ApiService()
                                    .updateUserToken(userId, token!);

                                if (tokenResult['success']) {
                                  _saveToken(token!);
                                  print(
                                      "Token Result:/// ${tokenResult['existingUser']}");
                                  if (widget.verify) {
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Home_Screen(
                                                  userData: result['data']
                                                      ['user'],
                                                )),
                                        (route) => false);
                                  } else {
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Home_Screen(
                                                  userData: result['data']
                                                      ['user'],
                                                )),
                                        (route) => false);
                                    termcontroller
                                        .showTermsConditionsDialog(context);
                                  }
                                } else {
                                  Utils().toastMessage(
                                      context, "Error Occurred", Colors.red);
                                }

                                setState(() {
                                  isLoading = false;
                                });
                              } else {
                                Utils().toastMessage(
                                    context, result['message'], Colors.red);
                              }
                            } catch (e) {
                              setState(() {
                                isLoading = false;
                              });
                              Utils().toastMessage(
                                  context, "Error Occurred", Colors.red);
                            }
                          },
                          child: isLoading
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Container(
                                  width: 300,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft:
                                          Radius.circular(21.9552001953125),
                                      topRight:
                                          Radius.circular(21.9552001953125),
                                      bottomLeft:
                                          Radius.circular(21.9552001953125),
                                      bottomRight:
                                          Radius.circular(21.9552001953125),
                                    ),
                                    color: Color(0xff102E44),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Verify OTP',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: Color.fromRGBO(255, 255, 255, 1),
                                        fontFamily: 'Montserrat',
                                        fontSize: 17,
                                        letterSpacing:
                                            0 /*percentages not used in flutter. defaulting to zero*/,
                                        fontWeight: FontWeight.normal,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
