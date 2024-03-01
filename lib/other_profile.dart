import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:omd/chat.dart';

import 'package:omd/services/api_service.dart';
import 'package:omd/services/chat_service.dart';

import 'package:omd/widgets/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'admin_chat_page.dart';
import 'edit_profile.dart';
import 'home.dart';

class OtherProfile extends StatefulWidget {
  final String userId;
  const OtherProfile({Key? key, required this.userId}) : super(key: key);

  @override
  State<OtherProfile> createState() => _OtherProfileState();
}

class _OtherProfileState extends State<OtherProfile> {
  String? currentUserId;

  Future<void> _fetchCurrentId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString('userId') ?? '';
    }); // Trigger a rebuild to update the UI with the fetched data
  }

  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    //   _fetchCurrentId();
    _fetchCurrentId();
    _fetchUserData();

    print('.......${currentUserId}');
  }

  Future<void> _fetchUserData() async {
    try {
      final result = await ApiService().getUserById(widget.userId);

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
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff102E44),
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(
                context,
              );
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
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Container(
                        child: userData?['profileImageUrl'] != null
                            ? Image.network(
                                userData?['profileImageUrl'] ?? "",
                                height: MediaQuery.of(context).size.height / 8,
                                width: MediaQuery.of(context).size.width / 4,
                              )
                            : Image.asset(
                                'assets/account.png',
                                height: MediaQuery.of(context).size.height / 8,
                                width: MediaQuery.of(context).size.width / 4,
                              ),
                      ),
                    ),
                    if (userData?['firstName'].isNotEmpty == true &&
                        userData?['lastName'].isNotEmpty == true)
                      Text(
                        '${userData?['firstName']} ${userData?['lastName']}',
                        style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.black)),
                      ),
                    if (userData?['email'].isNotEmpty == true)
                      const SizedBox(
                        height: 10,
                      ),
                    if (userData?['email'].isNotEmpty == true)
                      Text(
                        userData?['email'],
                        style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.black38)),
                      ),
                    if (userData?['Designation'].isNotEmpty == true)
                      const SizedBox(
                        height: 10,
                      ),
                    if (userData?['Designation'].isNotEmpty == true)
                      Text(
                        userData?['Designation'],
                        style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.black38)),
                      ),
                    if (userData?['Company']?.isNotEmpty == true)
                      const SizedBox(height: 5),
                    if (userData?['Company']?.isNotEmpty == true)
                      Text(
                        userData?['Company'],
                        style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Colors.black38)),
                      ),
                    if (userData?['Facebook']?.isNotEmpty == true)
                      const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (userData?['Facebook']?.isNotEmpty == true)
                          RowImageWithText(
                            image: 'assets/facebook.png',
                            text: userData?['Facebook']!,
                          ),
                        if (userData?['Linkedin']?.isNotEmpty == true)
                          const SizedBox(height: 5),
                        if (userData?['Linkedin']?.isNotEmpty == true)
                          RowImageWithText(
                              image: 'assets/linkd.png',
                              text: userData?['Linkedin']!),
                        if (userData?['Instagram']?.isNotEmpty == true)
                          SizedBox(height: 10),
                        if (userData?['Instagram']?.isNotEmpty == true)
                          RowImageWithText(
                              image: 'assets/insta.png',
                              text: userData?['Instagram']!),
                        if (userData?['Telegram']?.isNotEmpty == true)
                          SizedBox(
                            height: 10,
                          ),
                        if (userData?['Telegram']?.isNotEmpty == true)
                          RowImageWithText(
                              image: 'assets/telegram.png',
                              text: userData?['Telegram']!),
                        const SizedBox(height: 10),
                        if (userData?['Skype']?.isNotEmpty == true)
                          RowImageWithText(
                              image: 'assets/skype.png',
                              text: userData?['Skype']!),
                      ],
                    ),
                    if (currentUserId != userData?['userId']) ...{
                      TextButton(
                        onPressed: () async {
                          if (currentUserId! == '658c582ff1bc8978d2300823') {
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
                        },
                        style: TextButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.deepPurple,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                        ),
                        child: Text(
                          '      Chat With Me!      ',
                          style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.deepPurple,
                          )),
                        ),
                      ),
                    } else ...{
                      Container()
                    },
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
                          if (userData?['AboutMe']?.isNotEmpty == true)
                            Text(
                              userData?['AboutMe'],
                              maxLines: 20,
                              style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: Colors.black38)),
                            ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            userData?['mobileNumber'],
                            style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: Colors.black38)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ));
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Image.asset(
          image,
          height: 30,
          width: 30,
        ),
        SizedBox(
            width: 300,
            child: Text(
              text,
              maxLines: 3,
            ))
      ],
    );
  }
}
