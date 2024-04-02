import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omd/edit_profile.dart';
import 'package:omd/msgs_requests.dart';
import 'package:omd/pages/member_directory.dart';
import 'package:omd/profile.dart';
import 'package:omd/services/api_service.dart';
import 'package:omd/services/chat_service.dart';
import 'package:omd/sign_ups.dart';
import 'package:omd/widgets/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'contact_admin.dart';
import 'drawer_navigation.dart';
import 'home.dart';

Widget buildDrawer(BuildContext context, bool isSuspended) {
  return Drawer(
    child: FutureBuilder(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Handle error
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            String? currentUserId = snapshot.data!['userId'];
            String? firstName = snapshot.data!['firstName'];
            String? lastName = snapshot.data!['lastName'];
            String? email = snapshot.data!['email'];
            return ListView(
              children: <Widget>[
                Column(
                  children: [
                    Image.asset(
                      'assets/black_logo.png',
                      fit: BoxFit.cover,
                      height: 200,
                    ),
                  ],
                ),
                const Divider(
                  thickness: 1,
                ),
                ListTileWithNavigation(
                    icon: Icons.person,
                    text: 'PROFILE',
                    onTap: () async {
                      if (isSuspended) {
                        Utils().toastMessage(
                            context, "Your Account Has Suspended", Colors.red);
                      } else {
                        if (currentUserId!.isEmpty || currentUserId == null) {
                          Utils().toastMessage(
                              context, "Please Sign Up", Colors.red);
                          Get.offAll(() => Sign_Up());
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Profile()));
                        }
                      }
                    }),
                ListTileWithNavigation(
                    icon: Icons.chat,
                    text: 'CHATS',
                    onTap: () {
                      if (isSuspended) {
                        Utils().toastMessage(context,
                            'Your Account Has Suspended', Colors.redAccent);
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Msgs_Requests()));
                      }
                    }),
                ListTileWithNavigation(
                    icon: Icons.mobile_friendly,
                    text: 'CONTACT ADMIN',
                    onTap: () async {
                      if (isSuspended) {
                        Utils().toastMessage(context,
                            'Your Account Has Suspended', Colors.redAccent);
                      } else {
                        if (currentUserId!.isEmpty || currentUserId == null) {
                          Utils().toastMessage(
                              context, "Please Sign Up", Colors.red);
                          Get.offAll(() => Sign_Up());
                        } else if (firstName!.isEmpty ||
                            lastName!.isEmpty ||
                            email!.isEmpty) {
                          Utils().toastMessage(context,
                              "Please fill your name and email", Colors.red);
                          Get.offAll(() => Edit_Pro());
                        } else {
                          if (currentUserId == '658c582ff1bc8978d2300823') {
                            Navigator.pop(context);
                            Utils().toastMessage(context,
                                'You cannot chat with yourself', Colors.red);
                          } else {
                            String chatRoomId =
                                await ChatService().getChatRoomId(
                              currentUserId!,
                              // Replace with the service provider's user ID
                              '658c582ff1bc8978d2300823',
                            );
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ContactAdmin(
                                          chatRoomId: chatRoomId,
                                          receiverId:
                                              '658c582ff1bc8978d2300823',
                                        )));
                          }
                        }
                      }
                    }),
                ListTileWithNavigation(
                    icon: Icons.settings,
                    text: 'PROFILE SETTINGS',
                    onTap: () {
                      if (isSuspended) {
                        Utils().toastMessage(context,
                            'Your Account Has Suspended', Colors.redAccent);
                      } else {
                        if (currentUserId!.isEmpty || currentUserId == null) {
                          Utils().toastMessage(
                              context, "Please Sign Up", Colors.red);
                          Get.offAll(() => Sign_Up());
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Edit_Pro()));
                        }
                      }
                    }),
                ListTileWithNavigation(
                    icon: Icons.person_pin_outlined,
                    text: 'MEMBER DIRECTORY',
                    onTap: () {
                      if (isSuspended) {
                        Utils().toastMessage(
                            context, "Your Account Has Suspended", Colors.red);
                      } else {
                        Get.to(() => MemberDirectory());
                      }
                    }),
                GestureDetector(
                  onTap: () async {
                    final tokenResult = await ApiService()
                        .updateUserToken(currentUserId!, '12434');
                    print("TokenResult: ${tokenResult}");

                    if (tokenResult['success']) {
                      clearUserData();
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => Sign_Up()),
                          (route) => false);
                    }
                    if (currentUserId!.isEmpty || currentUserId == null) {
                      Utils().toastMessage(
                          context, "Please Sign Up", Colors.redAccent);
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => Sign_Up()),
                          (route) => false);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 200),
                    child: const Column(
                      children: [
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.logout,
                              color: Colors.red,
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              'Log Out',
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Handle loading state or error
            return Center(child: CircularProgressIndicator());
          }
        }),
  );
}

Future<Map<String, String>> getUserData() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String currentUserId = prefs.getString('userId') ?? '';
  String firstName = prefs.getString('firstName') ?? '';
  String lastName = prefs.getString('lastName') ?? '';
  String email = prefs.getString('email') ?? '';

  return {
    'userId': currentUserId,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
  };
}

Future<void> clearUserData() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('userId', '');
  prefs.setString('firstName', '');
  prefs.setString('lastName', '');
  prefs.setString('email', '');
  prefs.setString('mobileNumber', '');
  prefs.setString('profileImageUrl', '');
  prefs.setString('AboutMe', '');
  prefs.setString('Company', '');
  prefs.setString('Designation', '');
  prefs.setString('Facebook', '');
  prefs.setString('Instagram', '');
  prefs.setString('Linkedin', '');
  prefs.setString('Skype', '');
  prefs.setString('Telegram', '');
  prefs.setString('jwttoken', '');
  prefs.setString('sessionExpiration', '');
  prefs.setBool('iscontactverified', false);
  prefs.clear();
}
