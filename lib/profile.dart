import 'dart:io';

import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:omd/pages/guestUserScreen.dart';
import 'package:omd/services/api_service.dart';

import 'package:omd/settings.dart';
import 'package:omd/sign_ups.dart';

import 'package:omd/widgets/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'controller/deleteCOntroller.dart';
import 'edit_profile.dart';

import 'home.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? userId;
  String? profileImage;
  String? firstName;
  String? lastName;
  String? designation;
  String? companyName;
  String? facebook;
  String? instagram;
  String? linkedin;
  String? aboutMe;
  String? mobileNumber;
  String? email;
  String? skype;
  String? telegram;

  bool isEmailVerified = false;

  final DeleteController deleteController = Get.put(DeleteController());

  Future<void> _fetchUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId') ?? '';
      profileImage = prefs.getString('profileImageUrl') ?? '';
      firstName = prefs.getString('firstName');
      designation = prefs.getString('Designation');
      lastName = prefs.getString('lastName');
      companyName = prefs.getString('Company');
      facebook = prefs.getString('Facebook');
      instagram = prefs.getString('Instagram');
      linkedin = prefs.getString('LinkedIn');
      aboutMe = prefs.getString('AboutMe');
      email = prefs.getString('email');
      mobileNumber = prefs.getString('mobileNumber');
      skype = prefs.getString('Skype');
      telegram = prefs.getString('Telegram');

      var response = await deleteController.getUserByPhoneNumber(mobileNumber!);
      isEmailVerified = response.user.isEmailVerified;
      // No need to call setState here as it's not necessary for FutureBuilder
    } catch (error) {
      print('Error: $error');
      // Propagate the error to the FutureBuilder
      throw error;
    } // Trigger a rebuild to update the UI with the fetched data
  }

  @override
  void initState() {
    _fetchUserData();

    // TODO: implement initState
    super.initState();
  }

  bool isPressed = false;
  EmailOTP myauth = EmailOTP();
  TextEditingController otp = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff102E44),
          leading: GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Home_Screen()));
            },
            child: const Icon(
              Icons.arrow_back_ios_new_outlined,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Get.to(() => Edit_Pro());
                },
                icon: Icon(
                  Icons.edit,
                  color: Colors.white,
                )),
            IconButton(
                onPressed: () async {
                  (userId != null)
                      ? showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.35,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        "Do you really want to delete your profile ?? This action will remove your all chats and profile.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'Montserrat',
                                          fontSize: 17,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Color(0xff102E44),
                                              ),
                                              child: Text(
                                                "No",
                                                style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      255, 255, 255, 1),
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 17,
                                                ),
                                              )),
                                          ElevatedButton(
                                              onPressed: () async {
                                                String userId =
                                                    await deleteController
                                                        .getUserIdFromSharedPreferences();
                                                deleteController
                                                    .deleteUser(userId);
                                                Get.to(() =>
                                                    PermissionGuestUser());
                                                // Get.offAll(() => Sign_Up());
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Color(0xff102E44),
                                              ),
                                              child: Text(
                                                "Yes",
                                                style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      255, 255, 255, 1),
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 17,
                                                ),
                                              ))
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          })
                      : Utils().toastMessage(
                          context, "Please Sign Up", Colors.redAccent);
                  // String userId = await getUserIdFromSharedPreferences();
                  // deleteController.deleteUser(userId);
                  // Get.to(() => PermissionGuestUser());
                },
                icon: Icon(
                  Icons.delete,
                  color: Colors.white,
                )),
          ],
          centerTitle: true,
          title: Text('Profile',
              style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.white))),
        ),
        body: FutureBuilder<void>(
            future: _fetchUserData(), // Use _fetchUserData as the future
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Show a loading indicator while waiting for the data
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                // Show an error message if there's an error
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                return SingleChildScrollView(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Column(
                        children: [
                          if (profileImage!.isNotEmpty)
                            Center(
                              child: FutureBuilder<bool>(
                                // Simulate a delay of 2 seconds
                                future: Future.delayed(
                                    Duration(seconds: 2), () => true),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    // Show the loading indicator for 2 seconds
                                    return CircularProgressIndicator();
                                  } else {
                                    // Image is fully loaded, show the content
                                    return Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.network(
                                          profileImage!,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              8,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              4,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null) {
                                              // Image is fully loaded
                                              return child;
                                            } else {
                                              // Image is still loading, show a loading indicator
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                            )
                          else ...{
                            Center(
                              child: Container(
                                child: Image.asset(
                                  'assets/account.png',
                                  height:
                                      MediaQuery.of(context).size.height / 8,
                                  width: MediaQuery.of(context).size.width / 4,
                                ),
                              ),
                            ),
                          },
                          SizedBox(
                            height: 10,
                          ),
                          if (firstName!.isNotEmpty && lastName!.isNotEmpty)
                            Text(
                              '$firstName $lastName',
                              style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Colors.black)),
                            ),
                          if (email!.isNotEmpty)
                            Text(
                              email!,
                              style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: Colors.black38)),
                            ),
                          if (designation!.isNotEmpty)
                            Text(
                              designation!,
                              style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: Colors.black38)),
                            ),
                          if (companyName!.isNotEmpty)
                            Text(
                              companyName!,
                              style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: Colors.black38)),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (facebook!.isNotEmpty)
                          RowImageWithText(
                            image: 'assets/facebook.png',
                            text: facebook!,
                          ),
                        const SizedBox(height: 5),
                        if (linkedin!.isNotEmpty)
                          RowImageWithText(
                              image: 'assets/linkd.png', text: linkedin!),
                        if (linkedin!.isNotEmpty) SizedBox(height: 10),
                        if (instagram!.isNotEmpty)
                          RowImageWithText(
                              image: 'assets/insta.png', text: instagram!),
                        if (instagram!.isNotEmpty)
                          SizedBox(
                            height: 10,
                          ),
                        if (telegram!.isNotEmpty)
                          RowImageWithText(
                              image: 'assets/telegram.png', text: telegram!),
                        if (telegram!.isNotEmpty) const SizedBox(height: 10),
                        if (skype!.isNotEmpty)
                          RowImageWithText(
                              image: 'assets/skype.png', text: skype!),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(
                            thickness: 1,
                          ),
                          Text(
                            'About Me',
                            style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.black)),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          if (aboutMe!.isNotEmpty)
                            Text(
                              aboutMe!,
                              maxLines: 20,
                              style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: Colors.black38)),
                            ),
                          SizedBox(
                            height: 20,
                          ),
                          if (mobileNumber!.isNotEmpty)
                            Text(
                              mobileNumber!,
                              style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: Colors.black38)),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                    ),
                    if (email!.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Text(
                                      'Get Your Profile Verified \nWith Your Email Verification'),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          // backgroundColor: Color(0xff102E44),
                                          backgroundColor: Colors.black12),
                                      onPressed: () {
                                        Get.snackbar("To verify your email",
                                            "Please Fill your email",
                                            backgroundColor: Colors.redAccent,
                                            colorText: Colors.white);
                                        Get.to(() => Edit_Pro());
                                      },
                                      child: const Text(
                                        "Verify",
                                        style: TextStyle(color: Colors.white),
                                      ))
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (email!.isNotEmpty && isEmailVerified == false)
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Text(
                                      'Get Your Profile Verified \nWith Your Email Verification'),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          // backgroundColor: Color(0xff102E44),
                                          backgroundColor: Colors.black12),
                                      onPressed: () async {
                                        setState(() {
                                          isPressed = true;
                                        });
                                        myauth.setConfig(
                                            appEmail:
                                                "contactus@affiliatechatbox.com",
                                            appName: "Affiliate Chat Box ",
                                            userEmail: email!.trim().toString(),
                                            otpLength: 6,
                                            otpType: OTPType.digitsOnly);
                                        var template =
                                            "<body style=\"background-color: #e9ecef; width: 100% !important; height: 100% !important; padding: 0 !important; margin: 0 !important;\"><table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"max-width: 600px; margin: 0 auto;\"><tr><td align=\"center\" bgcolor=\"#e9ecef\" style=\"padding: 20px 0;\"><h1 style=\"margin: 20px 0; font-size: 32px; font-weight: 700; letter-spacing: -1px; line-height: 48px;\">Confirm Your Email Address</h1></td></tr></table><table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"max-width: 600px; margin: 0 auto;\"><tr><td align=\"left\" bgcolor=\"#ffffff\" style=\"padding: 20px;\"><p style=\"margin: 0; font-family: 'Source Sans Pro', Helvetica, Arial, sans-serif; font-size: 16px; line-height: 24px;\">Find the OTP below to confirm your email address. If you didn't request this verification, you can safely delete this email.</p></td></tr><tr><td align=\"center\" bgcolor=\"#ffffff\" style=\"padding: 20px;\"><table border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><tr><td align=\"center\" bgcolor=\"#1a82e2\" style=\"border-radius: 6px;\"><a href=\"#\" target=\"_blank\" style=\"display: inline-block; padding: 16px 36px; font-family: 'Source Sans Pro', Helvetica, Arial, sans-serif; font-size: 16px; color: #ffffff; text-decoration: none; border-radius: 6px;\">{{otp}}</a></td></tr></table></td></tr><tr><td align=\"left\" bgcolor=\"#ffffff\" style=\"padding: 20px;\"></td></tr><tr><td align=\"left\" bgcolor=\"#ffffff\" style=\"padding: 20px; border-bottom: 3px solid #d4dadf;\"><p style=\"margin: 0; font-family: 'Source Sans Pro', Helvetica, Arial, sans-serif; font-size: 16px; line-height: 24px;\">Cheers,<br> {{app_name}}</p></td></tr></table><table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"max-width: 600px; margin: 0 auto;\"><tr><td align=\"center\" bgcolor=\"#e9ecef\" style=\"padding: 20px; font-family: 'Source Sans Pro', Helvetica, Arial, sans-serif; font-size: 14px; line-height: 20px; color: #666;\"><p style=\"margin: 0;\">You received this email because we received a request for email verification for your account. If you didn't request email verification you can safely delete this email.</p></td></tr><tr><td align=\"center\" bgcolor=\"#e9ecef\" style=\"padding: 20px; font-family: 'Source Sans Pro', Helvetica, Arial, sans-serif; font-size: 14px; line-height: 20px; color: #666;\"></td></tr></table></body>";
                                        myauth.setTemplate(render: template);

                                        if (await myauth.sendOTP() == true) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content: Text("OTP has been sent"),
                                          ));
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content:
                                                Text("Something Went Wrong."),
                                          ));
                                        }
                                        if (isPressed) {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return Dialog(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 20),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              15),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          TextFormField(
                                                              controller: otp,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      hintText:
                                                                          "Enter OTP")),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          ElevatedButton(
                                                              style: ElevatedButton
                                                                  .styleFrom(
                                                                      // backgroundColor: Color(0xff102E44),
                                                                      backgroundColor:
                                                                          Colors
                                                                              .black12),
                                                              onPressed:
                                                                  () async {
                                                                if (await myauth
                                                                        .verifyOTP(
                                                                            otp:
                                                                                otp.text) ==
                                                                    true) {
                                                                  Get.snackbar(
                                                                    "",
                                                                    'Your Profile is Now Verified',
                                                                    backgroundColor:
                                                                        Colors
                                                                            .green,
                                                                    colorText:
                                                                        Colors
                                                                            .white,
                                                                  );
                                                                  deleteController
                                                                      .SendEmailverify(
                                                                          true,
                                                                          userId!);
                                                                  isEmailVerified =
                                                                      true;
                                                                  isPressed =
                                                                      false;

                                                                  Navigator.pushAndRemoveUntil(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              Home_Screen()),
                                                                      (route) =>
                                                                          false);
                                                                } else {
                                                                  deleteController
                                                                      .SendEmailverify(
                                                                          false,
                                                                          userId!);
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                          const SnackBar(
                                                                    content: Text(
                                                                        "Invalid OTP"),
                                                                  ));
                                                                  Navigator.pop(
                                                                      context);
                                                                }
                                                              },
                                                              child: const Text(
                                                                "Verify Otp",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ))
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              });
                                        }
                                      },
                                      child: const Text(
                                        "Verify",
                                        style: TextStyle(color: Colors.white),
                                      ))
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ));
              }
            }));
  }
}

class RowImageWithText extends StatelessWidget {
  final String image;
  final String text;
  RowImageWithText({
    super.key,
    required this.image,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Image.asset(
            image,
            height: 30,
            width: 30,
          ),
          SizedBox(
              width: 250,
              child: Text(
                text,
                maxLines: 3,
              )),
        ],
      ),
    );
  }
}
