import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omd/edit_profile.dart';
import 'package:omd/services/api_service.dart';
import 'package:omd/services/chat_service.dart';
import 'package:omd/settings.dart';
import 'package:omd/widgets/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin_chat_page.dart';
import 'chat.dart';
import 'home.dart';

class NotAcceptedProfile extends StatefulWidget {
  final String otherUserId;
  NotAcceptedProfile({super.key, required this.otherUserId});

  @override
  State<NotAcceptedProfile> createState() => _NotAcceptedProfileState();
}

class _NotAcceptedProfileState extends State<NotAcceptedProfile> {
  Map<String, dynamic>? userData;
  String? currentUserId;
  String? firstName;
  String? lastName;
  String? email;

  Future<void> _fetchCurrentId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString('userId') ?? '';
      firstName = prefs.getString('firstName');
      lastName = prefs.getString('lastName');
      email = prefs.getString('email');
    }); // Trigger a rebuild to update the UI with the fetched data
  }

  Future<void> _fetchUserData() async {
    try {
      final result = await ApiService().getUserById(widget.otherUserId);

      if (result['message'] == 'User Data fetched') {
        setState(() {
          userData = result['user'];
        });
        print("USer data fetched Successfully");
      } else {
        // Handle error scenario
        print(result['message']);
      }
    } catch (error) {
      // Handle error scenario
      print('Error: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCurrentId();
  }

  @override
  Widget build(BuildContext context) {
    _fetchUserData();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff102E44),
          leading: GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Home_Screen()));
            },
            child: const Icon(
              Icons.arrow_back_ios_new_outlined,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          title: Text('Profile',
              style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.white))),
        ),
        body: userData != null
            ? FutureBuilder<void>(
                future: _fetchUserData(), // Use _fetchUserData as the future
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    // Show an error message if there's an error
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    return SingleChildScrollView(
                        child: Center(
                      child: Column(children: [
                        SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: Container(
                            //alignment: AlignmentDirectional.topStart,
                            // margin: const EdgeInsets.only(left: 100),
                            child: userData != null &&
                                    userData!['profileImageUrl'] != null
                                ? Image.network(
                                    userData?['profileImageUrl']!,
                                    height:
                                        MediaQuery.of(context).size.height / 8,
                                    width:
                                        MediaQuery.of(context).size.width / 4,
                                  )
                                : Image.asset(
                                    'assets/account.png',
                                    height:
                                        MediaQuery.of(context).size.height / 8,
                                    width:
                                        MediaQuery.of(context).size.width / 4,
                                  ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          '${userData?['firstName']} ${userData?['lastName']}',
                          style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: Colors.black)),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextButton(
                          onPressed: () async {
                            if (firstName!.isEmpty ||
                                lastName!.isEmpty ||
                                email!.isEmpty) {
                              Utils().toastMessage(
                                  context,
                                  "Please fill your name and email",
                                  Colors.red);
                              Get.to(() => Edit_Pro());
                            } else {
                              if (currentUserId == userData?['_id']) {
                                Utils().toastMessage(
                                    context,
                                    "You cannot chat with yourself",
                                    Colors.red);
                              } else if (currentUserId! ==
                                  '658c582ff1bc8978d2300823') {
                                String chatRoomId =
                                    await ChatService().getChatRoomId(
                                  currentUserId!,
                                  // Replace with the service provider's user ID
                                  userData?['_id'],
                                );
                                print(chatRoomId);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AdminChatPage(
                                            chatRoomId: chatRoomId,
                                            receiverId: userData?['_id'])));
                              } else {
                                String chatRoomId =
                                    await ChatService().getChatRoomId(
                                  currentUserId!,
                                  // Replace with the service provider's user ID
                                  userData?['_id'],
                                );
                                print(chatRoomId);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatPage(
                                            chatRoomId: chatRoomId,
                                            receiverId: userData?['_id'])));
                              }
                            }
                          },
                          style: TextButton.styleFrom(
                            side: const BorderSide(
                              color: Colors.deepPurple,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Unblock profile send chat invite',
                              style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Colors.deepPurple,
                              )),
                            ),
                          ),
                        )
                      ]),
                    ));
                  }
                })
            : Center(child: CircularProgressIndicator()));
  }
}
