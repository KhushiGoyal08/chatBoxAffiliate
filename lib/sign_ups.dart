import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:omd/controller/deleteCOntroller.dart';
import 'package:omd/services/api_service.dart';
import 'package:omd/services/auth_service.dart';
import 'package:omd/verify_otp.dart';
import 'package:omd/widgets/utils.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Sign_Up extends StatefulWidget {
  static String verify = '';
  const Sign_Up({Key? key}) : super(key: key);
  @override
  State<Sign_Up> createState() => _Sign_UpState();
}

class _Sign_UpState extends State<Sign_Up> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();
  final DeleteController IsFirstTimeUser =Get.put(DeleteController());
  Future<void> _saveFlag(String flag) async {
    if (flag.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString('flag', flag);
      print("Flag is successfully saved");
    } else {
      print("Flag is empty");
    }
  }

  String? otpCode;

  String? _phoneNumber;
  String? _countryCode;
  String? _countryFlagIcon;
  bool isLoading = false;
  final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Container(
            margin: const EdgeInsets.only(top: 40, left: 20, right: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    'assets/logo-black.png',
                    height: 300,
                    width: 300,
                  ),
                  const Text(
                    'Sign Up/Sign In',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Color.fromRGBO(91, 91, 91, 1),
                        fontFamily: 'Montserrat',
                        fontSize: 24,
                        letterSpacing:
                            0 /*percentages not used in flutter. defaulting to zero*/,
                        fontWeight: FontWeight.w700,
                        height: 1),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Sign up using your phone number',
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
                    'with the code which we sent',
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
                  const SizedBox(height: 30),
                  const Text(
                    'Enter Mobile number',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromRGBO(185, 185, 185, 1),
                        fontFamily: 'SF Pro Text',
                        fontSize: 16,
                        letterSpacing:
                            0 /*percentages not used in flutter. defaulting to zero*/,
                        fontWeight: FontWeight.normal,
                        height: 1.5000000298979959),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          IntlPhoneField(
                            initialCountryCode: 'IN',
                            style: TextStyle(fontSize: 17),
                            dropdownIcon: Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xff102E44),
                            ),
                            dropdownTextStyle: TextStyle(fontSize: 15),
                            decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xff102E44)),
                                ),
                                labelText: 'Phone Number',
                                labelStyle: TextStyle(color: Colors.black),
                                border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xff102E44)),
                                )),
                            controller: _phoneNumberController,
                            onChanged: (phone) {
                              String countryCode = phone.countryISOCode;
                              _countryFlagIcon = countryCode
                                  .toUpperCase()
                                  .replaceAllMapped(
                                      RegExp(r'[A-Z]'),
                                      (match) => String.fromCharCode(
                                          match.group(0)!.codeUnitAt(0) +
                                              127397));
                              print(_countryFlagIcon);
                              _countryCode = phone.completeNumber;
                              print(_countryCode);
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 10.0),
                        ],
                      ),
                    ),
                  ),
                  // Container(
                  //   margin: const EdgeInsets.only(left: 60,right: 60),
                  //   child: const Divider(
                  //       color: Color(0xff102E44),
                  //       thickness: 0.4984000027179718
                  //   ),
                  // ),
                  const SizedBox(height: 20),
                  // Figma Flutter Generator Rectangle1Widget - RECTANGLE
                  GestureDetector(
                    onTap: () async {
                      if (_formKey.currentState!.validate()) {
                        // Construct the phone number using the country code and input

                        final phoneNumber =
                            '$_countryCode${_phoneNumberController.text}';

                        // print(".................${phoneNumber}");
                        print("...............Firebase Number.${_countryCode}");

                        setState(() {
                          isLoading = true;
                        });
                        try {
                          final apiResult = await ApiService()
                              .registerAndVerifyContact(_countryCode!);

                          await _saveFlag(_countryFlagIcon!);
                          print("API RESULT............${apiResult}");
                          if (apiResult['success']) {
                         final res= await    IsFirstTimeUser.getUserByPhoneNumber(_countryCode!);
                       bool  isFirstTime=res.user.isverified;
                              // final res=ApiService().getUserById();
                            // final isVerify=apiResult['data']['user']['isverified'];
                            // print("\n"+isVerify);
                            auth.verifyPhoneNumber(
                                phoneNumber: _countryCode,
                                verificationCompleted:
                                    (PhoneAuthCredential credential) {
                                  otpCode = credential.smsCode;
                                  setState(() {
                                    isLoading = false;
                                  });
                                },

                                verificationFailed: (e) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  print(e);
                                  Utils().toastMessage(
                                      context, e.toString(), Colors.red);
                                },
                                codeSent:
                                    (String verificationId, int? resendToken) async{
                                  Sign_Up.verify = verificationId;

                                  print('.......${otpCode}');
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: ((context) => Verify_OTP(
                                            verify: isFirstTime,
                                                phoneNumber: _countryCode!,
                                                countryFlag: _countryFlagIcon!,
                                              ))));
                                  setState(() {
                                    isLoading = false;
                                  });
                                },
                                codeAutoRetrievalTimeout: (e) {
                                  Utils().toastMessage(
                                      context, "Error Occurred", Colors.red);
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                          } else {
                            Utils().toastMessage(
                                context, apiResult['message'], Colors.red);
                            setState(() {
                              isLoading = false;
                            });
                          }
                        } catch (error) {
                          Utils().toastMessage(context,
                              'Failed to call API. $error', Colors.red);
                          setState(() {
                            isLoading = false;
                          });
                        }
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
                                topLeft: Radius.circular(21.9552001953125),
                                topRight: Radius.circular(21.9552001953125),
                                bottomLeft: Radius.circular(21.9552001953125),
                                bottomRight: Radius.circular(21.9552001953125),
                              ),
                              color: Color(0xff102E44),
                            ),
                            child: // Figma Flutter Generator SignupWidget - TEXT
                                const Center(
                              child: Text(
                                'Send OTP',
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
        ),
      ),
    );
  }
}
