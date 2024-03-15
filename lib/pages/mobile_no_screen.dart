import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:omd/edit_profile.dart';
import 'package:omd/services/api_service.dart';
import 'package:omd/widgets/utils.dart';

import 'package:shared_preferences/shared_preferences.dart';

class UpdatePhoneNumber extends StatefulWidget {
  static String verify = '';
  const UpdatePhoneNumber({Key? key}) : super(key: key);
  @override
  State<UpdatePhoneNumber> createState() => _UpdatePhoneNumber();
}

class _UpdatePhoneNumber extends State<UpdatePhoneNumber> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();



  String? otp;
  String? _phoneNumber;
  String? _countryCode;
  String? _countryFlagIcon;
  bool isPhoneVerified=false;
  bool isLoading = false;
  final auth = FirebaseAuth.instance;
  Future<void> verifyPhoneNumber(String newPhoneNumber,BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        PhoneVerificationCompleted verificationCompleted =
            (PhoneAuthCredential credential) async {

          print('Phone number updated successfully');
        };

        PhoneVerificationFailed verificationFailed =
            (FirebaseAuthException authException) {
              Get.offAll(()=>Edit_Pro());
              Utils().toastMessage(context, '${authException.message}',Colors.red);
          print('Phone verification failed: ${authException.message}');
        };

        PhoneCodeSent codeSent =
            (String verificationId, int? resendToken) async {
         UpdatePhoneNumber.verify = verificationId;


          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: TextFormField(
                    onChanged: (val) {
                      otp = val;
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(6), // Limit to 6 digits
                    ],
                    decoration: InputDecoration(
                      label: Text("Enter OTP"),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black12),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(46),
                          topRight: Radius.circular(46),
                          bottomLeft: Radius.circular(46),
                          bottomRight: Radius.circular(46),
                        ),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        // borderSide: BorderSide(color: Colors.blue, width: 0.4),
                        borderSide: BorderSide(color: Colors.black12),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(46),
                          topRight: Radius.circular(46),
                          bottomLeft: Radius.circular(46),
                          bottomRight: Radius.circular(46),
                        ),
                      ),
                      contentPadding: EdgeInsets.all(15),
                      hintText: "Enter OTP",
                      hintStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          color: Colors.black,
                          letterSpacing: -0.33,
                          fontFamily: 'Montserrat'),
                    ),
                  ),
                  actions: [
                    ElevatedButton(
                        onPressed: () async {
                          try{
                            PhoneAuthCredential credential =
                            PhoneAuthProvider.credential(
                              verificationId: UpdatePhoneNumber
                                  .verify, // Verification ID received during phone number change
                              smsCode:
                              otp!, // Confirmation code sent to the new phone number
                            );
                            await user.updatePhoneNumber(credential);
                            Utils().toastMessage(context, "User Number Update Successfully", Colors.black);
                            print("USer Phone NO Update Successfully");
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            prefs.setString('mobileNumber', newPhoneNumber);
                            print(prefs.getString('mobileNumber'));
                            await   ApiService().verifyUser(newPhoneNumber);
                            setState(() {
                              isPhoneVerified=true;
                            });
                            // await ApiService().registerAndUpdateProfile(userId: userId!, profilePicture: File(profileImage!), firstName: firstName.text, lastName: lastName.text, email: email.text, mobileNumber: newPhoneNumber, linkedIn: linkedin.text, skype: skype.text, telegram: telegram.text, instagram: instagram.text, facebook: facebook.text, company: company.text, designation:designation.text, aboutMe: aboutMe.text, token: token!, flag: flag);
                          }
                          catch(e){

                            Utils().toastMessage(context, 'Phone Number Not Updated', Colors.redAccent);
                            Utils().toastMessage(context, '$e', Colors.redAccent);
                          }

                        Get.offAll(()=>Edit_Pro());
                        },
                        child: Text("Verify OTP"))
                  ],
                );
              });

          setState(() async {

            isLoading = false;
          });
        };

        await FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: newPhoneNumber,
            verificationCompleted: verificationCompleted,
            verificationFailed: verificationFailed,
            codeSent: codeSent,
            codeAutoRetrievalTimeout: (e) {
              Get.offAll(()=>Edit_Pro());
              Utils().toastMessage(context, "Error Occurred", Colors.red);
              setState(() {
                isLoading = false;
              });
            });
      } else {
        print('User not signed in');
      }
    } catch (e) {
      print('Error verifying phone number: $e');
    }
  }
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
                    'Update Your Phone Number',
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
                    'Update using your new phone number',
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

        },
        onSubmitted: (phone) async {
          User user = FirebaseAuth.instance.currentUser!;
          phone = _countryCode!;
          SharedPreferences prefs =
              await SharedPreferences.getInstance();
          var ph = prefs.getString('mobileNumber');
          print(ph);
          print(phone);
          if (ph != phone) {
            try {
              verifyPhoneNumber(phone,context);
            } catch (error) {
              Get.offAll(()=>Edit_Pro());
              Utils().toastMessage(context,
                  'Failed to call API. $error', Colors.red);
              setState(() {
                isLoading = false;
              });
            }
          }
          else{
            Utils().toastMessage(context, 'Same Number', Colors.black);
          }
        },
                          ),
                          const SizedBox(height: 10.0),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),


                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
