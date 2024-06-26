import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omd/contact_admin.dart';
import 'package:omd/edit_profile.dart';
import 'package:omd/msgs_requests.dart';
import 'package:omd/pages/partnerpage.dart';
import 'package:omd/search_screen.dart';
import 'package:omd/services/chat_service.dart';
import 'package:omd/pages/member_directory.dart';
import 'package:omd/sign_ups.dart';
import 'package:omd/swiper.dart';
import 'package:omd/posts.dart';
import 'package:omd/widgets/utils.dart';
import 'package:omd/write_post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'build_drawer.dart';
import 'controller/deleteCOntroller.dart';

class Home_Screen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  Home_Screen({super.key, this.userData});

  @override
  State<Home_Screen> createState() => _Home_ScreenState();
}

class _Home_ScreenState extends State<Home_Screen> {
  String? currentUserId;
  String? firstName;
  String? lastName;
  String? email;
  String? mobile;
  bool user = false;
  final deleteController = Get.put(DeleteController());
  bool? isSuspended = false;
  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getString('userId') ?? '';
    firstName = prefs.getString('firstName');
    lastName = prefs.getString('lastName');
    email = prefs.getString('email');
    mobile = prefs.getString('mobileNumber');
    getUserData();
    if (firstName == '') {
      setState(() {
        user = true;
      });
    }
    setState(() {}); // Trigger a rebuild to update the UI with the fetched data
  }

  List<Widget> screens = [
    // Home(),
    // Settings(),
    // Person(),
    // Menu(),
  ];
  Future<void> getUserData() async {
    final user = await deleteController.getUserByPhoneNumber(mobile!);

    isSuspended = user.user.isSuspended;
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('users', arrayContains: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          int _totalUnreadMessageCount = 0;

          if (snapshot.hasData) {
            final chats = snapshot.data!.docs;

            for (final chat in chats) {
              final unreadCountTo = (chat['unreadCountTo'] ?? 0) as int;
              final unreadCountFrom = (chat['unreadCountFrom'] ?? 0) as int;

              _totalUnreadMessageCount += currentUserId == chat['receiverId']
                  ? unreadCountTo
                  : unreadCountFrom;
            }
          }

          return Scaffold(
            drawer: buildDrawer(context, isSuspended!),
            appBar: AppBar(
              iconTheme: const IconThemeData(color: Colors.black),
              backgroundColor: Colors.white,
              title: Image.asset(
                'assets/logo-black.png',
                height: 150,
              ),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 15),
                  child: InkWell(
                    onTap: () {
                      if (isSuspended!) {
                        Utils().toastMessage(context,
                            'Your Account Has Suspended', Colors.redAccent);
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Msgs_Requests()));
                      }
                    },
                    child: Stack(
                      children: [
                        const Icon(
                          Icons.forward_to_inbox,
                          color: Colors.black,
                        ),
                        if (_totalUnreadMessageCount > 0)
                          Positioned(
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 8,
                                minHeight: 8,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () {
                      if (isSuspended!) {
                        Utils().toastMessage(context,
                            'Your Account Has Suspended', Colors.redAccent);
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchScreen()));
                      }
                    },
                    child: Icon(
                      Icons.search,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(height: 200, child: SwiperDemo()),
                  Container(height: 600, child: Posts()),
                ],
              ),
            ),
            floatingActionButton: SizedBox(
              height: 50,
              width: 50,
              child: FloatingActionButton(
                  backgroundColor: const Color(0xff102E44),
                  //foregroundColor: Colors.black,
                  mini: true,
                  onPressed: () {
                    if (isSuspended!) {
                      Utils().toastMessage(context,
                          'Your Account Has Suspended', Colors.redAccent);
                    } else {
                      if (currentUserId!.isEmpty || currentUserId == null) {
                        Utils().toastMessage(
                            context, "Please Sign Up", Colors.red);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Sign_Up()));
                      }
                      if (firstName!.isEmpty ||
                          lastName!.isEmpty ||
                          email!.isEmpty) {
                        Utils().toastMessage(context,
                            "Please fill the name and email", Colors.red);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Edit_Pro()));
                      } else {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => WPost()));
                      }
                    }
                  },
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 35,
                  )),
            ),
            bottomNavigationBar: BottomNavigationBar(
                unselectedItemColor: Colors.grey,
                selectedItemColor: Color(0xff102E44),
                // type: BottomNavigationBarType.fixed,

                items: [
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.home,
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_pin_outlined),
                    label: 'Members',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.handshake_outlined),
                    label: 'Our Partners',
                  ),
                ],
                onTap: (int index) async {
                  if (index == 1) {
                    if (isSuspended!) {
                      Utils().toastMessage(
                          context, "Your Account Has Suspended", Colors.red);
                    } else {
                      if (currentUserId!.isEmpty || currentUserId == null) {
                        Utils().toastMessage(
                            context, "Please Sign Up", Colors.red);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Sign_Up()));
                      } else {
                        // if (firstName!.isEmpty ||
                        //     lastName!.isEmpty ||
                        //     email!.isEmpty) {
                        //   Utils().toastMessage(context,
                        //       "Please fill your name and email", Colors.red);
                        //   Get.to(() => Edit_Pro());
                        // } else {
                        // if (currentUserId == '658c582ff1bc8978d2300823') {
                        //   Utils().toastMessage(context,
                        //       'You cannot chat with yourself', Colors.red);
                        // } else {
                        // String chatRoomId = await ChatService().getChatRoomId(
                        //   currentUserId!,
                        //   '658c582ff1bc8978d2300823',
                        // );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MemberDirectory(),

                            // ContactAdmin(
                            //   chatRoomId: chatRoomId,
                            //   receiverId: '658c582ff1bc8978d2300823',
                            // ),
                          ),
                        );
                      }
                    }
                    // }
                    // }
                  }
                  if (index == 2) {
                    if (isSuspended!) {
                      Utils().toastMessage(
                          context, "Your Account Has Suspended", Colors.red);
                    } else {
                      if (currentUserId!.isEmpty || currentUserId == null) {
                        Utils().toastMessage(
                            context, "Please Sign Up", Colors.red);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Sign_Up()));
                      }
                      if (firstName!.isEmpty ||
                          lastName!.isEmpty ||
                          email!.isEmpty) {
                        Utils().toastMessage(context,
                            "Please fill your name and email", Colors.red);
                        Get.to(() => Edit_Pro());
                      } else {
                        Get.to(() => PartnerPage());
                      }
                    }
                  }
                }),
          );
        });
  }
}
