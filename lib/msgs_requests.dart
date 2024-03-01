import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:omd/chat_request.dart';
import 'package:omd/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat.dart';

class Msgs_Requests extends StatefulWidget {
  @override
  State<Msgs_Requests> createState() => _Msgs_RequestsState();
}

class _Msgs_RequestsState extends State<Msgs_Requests> {
  String? currentUserId;
  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getString('userId') ?? '';

    setState(() {}); // Trigger a rebuild to update the UI with the fetched data
  }

  String _formatTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedTime = DateFormat.jm().format(dateTime);
    return formattedTime;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            margin: const EdgeInsets.only(top: 70),
            child: DefaultTabController(
                length: 2, // Number of tabs
                child: Column(children: [
                  Container(
                    height: 40,
                    margin: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xffEBEBEB),
                      borderRadius: BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                    ),
                    child: TabBar(
                      indicator: BoxDecoration(
                        border: Border.all(
                          color: Color(0xffDDDDDD),
                          width: 3.0,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(3.0),
                        ),
                        color: const Color(
                            0xffFFFFFF), //<-- selected tab background color
                      ),
                      indicatorColor: Colors.transparent,
                      labelColor: Colors.black, // Text color when selected
                      unselectedLabelColor:
                          Colors.grey, // Text color when not selected
                      labelPadding: EdgeInsets.symmetric(horizontal: 1.0),

                      tabs: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Tab(text: 'All Messages'),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Tab(text: 'All Requests'),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(children: [
                      StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('chats')
                              .orderBy('timestamp', descending: true)
                              .where('isRequested', isEqualTo: 'accepted')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return Center(
                                  child: Text("Error: ${snapshot.error}"));
                            }

                            final chats = snapshot.data!.docs
                                .where((element) {
                                  List<String> ids = element.id.split('_');
                                  return ids.contains(currentUserId);
                                })
                                .map((element) => element.data()!)
                                .toList();
                            if (chats.isEmpty) {
                              return Center(
                                  child: Text(
                                "No chats available",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 20,
                                ),
                              ));
                            } else {
                              return ListView.builder(
                                itemCount: chats.length,
                                itemBuilder: (context, index) {
                                  final chatData =
                                      chats[index] as Map<String, dynamic>;
                                  final users =
                                      List<String>.from(chatData['users']);
                                  users.remove(currentUserId);

                                  return FutureBuilder(
                                      future:
                                          ApiService().getUserById(users.first),
                                      builder: (context, userSnapshot) {
                                        if (userSnapshot.hasError) {
                                          return Text(
                                              "Error: ${userSnapshot.error}");
                                        }
                                        if (userSnapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          // Handle loading state if needed
                                          return Container();
                                        }

                                        final user = userSnapshot.data != null
                                            ? userSnapshot.data!['user']
                                            : null;
                                        print("User.... $user");

                                        final String chatroomId =
                                            chatData['chatRoomId'];
                                        final int unreadCountTo =
                                            chatData['unreadCountTo'] ?? 0;
                                        final int unreadCountFrom =
                                            chatData['unreadCountFrom'] ?? 0;
                                        final bool isReceiver =
                                            currentUserId! !=
                                                chatData['receiverId'];
                                        final String lastMessage =
                                            chatData['lastMessage'];
                                        if (user == null) {
                                          // Handle the case where user data is null (admin deleted the user)
                                          return Container();
                                        }
                                        return Column(children: [
                                          ListTile(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ChatPage(
                                                            chatRoomId:
                                                                chatroomId,
                                                            receiverId:
                                                                user['_id'],
                                                          )));
                                            },
                                            leading: CircleAvatar(
                                                radius: 30,
                                                child: ClipOval(
                                                  child: user['profileImageUrl'] !=
                                                              null &&
                                                          user['profileImageUrl']
                                                              .toString()
                                                              .isNotEmpty
                                                      ? Image.network(
                                                          user[
                                                              'profileImageUrl'],
                                                          width:
                                                              160, // Adjust the width and height as needed
                                                          height: 160,
                                                          fit: BoxFit.cover,
                                                        )
                                                      : Image.asset(
                                                          'assets/account.png',
                                                          width:
                                                              120, // Adjust the width and height as needed
                                                          height: 120,
                                                          fit: BoxFit.cover,
                                                        ),
                                                )),
                                            trailing: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  if (chatData['users']
                                                      .contains(currentUserId))
                                                    if (isReceiver
                                                        ? unreadCountFrom > 0
                                                        : unreadCountTo >
                                                            0) ...?[
                                                      CircleAvatar(
                                                        backgroundColor: Color(
                                                            0xff102E44), // You can customize the color
                                                        radius: 8,
                                                        child: Text(
                                                          isReceiver
                                                              ? unreadCountFrom
                                                                  .toString()
                                                              : unreadCountTo
                                                                  .toString(),
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                    ],
                                                  Text(
                                                    _formatTime(
                                                        chatData['timestamp']),
                                                    style: GoogleFonts.poppins(
                                                        textStyle:
                                                            const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 12,
                                                                color: Color(
                                                                    0xff919191))),
                                                  ),
                                                ]),
                                            title: Text(
                                              "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}",
                                              style: GoogleFonts.poppins(
                                                  textStyle: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14)),
                                              //  style: TextStyle(fontSize: 20,fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                                            ),
                                            subtitle: lastMessage == '' ||
                                                    lastMessage.isEmpty
                                                ? Row(
                                                    children: [
                                                      Icon(
                                                        Icons.image,
                                                        size: 16,
                                                      ),
                                                      Text("Picture")
                                                    ],
                                                  )
                                                : Text(
                                                    lastMessage,
                                                    style: GoogleFonts.poppins(
                                                        textStyle:
                                                            const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 12,
                                                                color: Color(
                                                                    0xff919191))),
                                                  ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Divider(),
                                          SizedBox(
                                            height: 10,
                                          )
                                        ]);
                                      });
                                },
                              );
                            }
                          }),
                      StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('chats')
                              .orderBy('timestamp', descending: true)
                              .where('isRequested',
                                  whereIn: ['pending', 'declined']).snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return Center(
                                  child: Text("Error: ${snapshot.error}"));
                            }

                            final chats = snapshot.data!.docs
                                .where((element) {
                                  List<String> ids = element.id.split('_');
                                  return ids.contains(currentUserId);
                                })
                                .map((element) => element.data()!)
                                .toList();
                            print(chats);
                            if (chats.isEmpty) {
                              return Center(
                                  child: Text(
                                "No chats available",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 20,
                                ),
                              ));
                            } else {
                              return ListView.builder(
                                  itemCount: chats.length,
                                  itemBuilder: (context, index) {
                                    final chatData =
                                        chats[index] as Map<String, dynamic>;
                                    final users =
                                        List<String>.from(chatData['users']);
                                    users.remove(currentUserId);

                                    return FutureBuilder(
                                        future: ApiService()
                                            .getUserById(users.first),
                                        builder: (context, userSnapshot) {
                                          if (userSnapshot.hasError) {
                                            return Text(
                                                "Error: ${userSnapshot.error}");
                                          }
                                          if (userSnapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            // Handle loading state if needed
                                            return Container();
                                          }

                                          final user =
                                              userSnapshot.data!['user'];
                                          print("User.... $user");
                                          final String requestStatus =
                                              chatData['isRequested'];
                                          final String chatroomId =
                                              chatData['chatRoomId'];
                                          final int unreadCountTo =
                                              chatData['unreadCountTo'] ?? 0;
                                          final int unreadCountFrom =
                                              chatData['unreadCountFrom'] ?? 0;
                                          final bool isReceiver =
                                              currentUserId ==
                                                  chatData['receiverId'];
                                          final String lastMessage =
                                              chatData['lastMessage'];
                                          print(
                                              'Last Message........: $lastMessage');
                                          return Column(
                                            children: [
                                              ListTile(
                                                onTap: () {
                                                  print(
                                                      "Navigating to Chat_Request with receiverId: ${user['_id']}");
                                                  print(
                                                      "Navigating to Chat_Request with receiverId: $currentUserId");

                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Chat_Request(
                                                                chatRoomId:
                                                                    chatroomId,
                                                                receiverId:
                                                                    user['_id'],
                                                                requestStatus:
                                                                    requestStatus,
                                                              )));
                                                },
                                                leading: CircleAvatar(
                                                    radius: 30,
                                                    child: ClipOval(
                                                      child: user['profileImageUrl'] !=
                                                                  null &&
                                                              user['profileImageUrl']
                                                                  .toString()
                                                                  .isNotEmpty
                                                          ? Image.network(
                                                              user[
                                                                  'profileImageUrl'],
                                                              width:
                                                                  160, // Adjust the width and height as needed
                                                              height: 160,
                                                              fit: BoxFit.cover,
                                                            )
                                                          : Image.asset(
                                                              'assets/account.png',
                                                              width:
                                                                  120, // Adjust the width and height as needed
                                                              height: 120,
                                                              fit: BoxFit.cover,
                                                            ),
                                                    )),
                                                trailing: Text(
                                                  _formatTime(
                                                      chatData['timestamp']),
                                                  style: GoogleFonts.poppins(
                                                      textStyle:
                                                          const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 12,
                                                              color: Color(
                                                                  0xff919191))),
                                                ),
                                                title: Text(
                                                  "${user['firstName'] ?? "No"} ${user['lastName'] ?? 'Name'}",
                                                  style: GoogleFonts.poppins(
                                                      textStyle:
                                                          const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 14)),
                                                  //  style: TextStyle(fontSize: 20,fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                                                ),
                                                subtitle: lastMessage == '' ||
                                                        lastMessage.isEmpty
                                                    ? Row(
                                                        children: [
                                                          Icon(
                                                            Icons.image,
                                                            size: 16,
                                                          ),
                                                          Text("Picture")
                                                        ],
                                                      )
                                                    : Text(
                                                        lastMessage,
                                                        style: GoogleFonts.poppins(
                                                            textStyle: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 12,
                                                                color: Color(
                                                                    0xff919191))),
                                                      ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Divider(),
                                              SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          );
                                        });
                                  });
                            }
                          })
                    ]),
                  )
                ]))));
  }
}
