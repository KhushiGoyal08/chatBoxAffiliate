// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:omd/home.dart';
import 'package:omd/other_profile.dart';
import 'package:omd/services/api_service.dart';
import 'package:omd/services/chat_service.dart';
import 'package:omd/widgets/chat_message.dart';

class Chat_Request extends StatefulWidget {
  String chatRoomId;
  String receiverId;
  String requestStatus;
  Chat_Request({
    Key? key,
    required this.chatRoomId,
    required this.receiverId,
    required this.requestStatus,
  }) : super(key: key);

  @override
  State<Chat_Request> createState() => _Chat_RequestState();
}

class _Chat_RequestState extends State<Chat_Request> {
  TextEditingController chatMessage = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  String? receiverId;
  bool? isRequested;
  bool? isSender;
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;
  bool _isUploading = false;
  bool? isReceiver;

  String? currentUserId;
  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getString('userId') ?? '';

    setState(() {}); // Trigger a rebuild to update the UI with the fetched data
  }

//  String? requestStatus;

  // Function to handle the decline action
  Future<void> _declineRequest() async {
    // Update the request status to "declined" in Firestore
    await ChatService().declineRequest(widget.chatRoomId);

    // Update the UI to show the declined status
    setState(() {
      widget.requestStatus = 'declined';
    });
  }

  Future<void> initializeData() async {
    await _fetchUserData();
    await fetchUserData();
    final userIds = widget.chatRoomId.split('_');
    receiverId = userIds.firstWhere((id) => id != currentUserId);
    print("Navigating to Chat_Request with receiverId: ${widget.receiverId}");

    isReceiver =
        await ChatService().checkIsReceiver(currentUserId!, receiverId!);
    setState(() {});
    // Check if the current user is the sender
    isSender = currentUserId != widget.receiverId;

    // Check if the request has been declined

    print("Navigating to Chat_Request with receiverId: $currentUserId");
  }

  Map<String, dynamic>? userData;
  Future<void> fetchUserData() async {
    try {
      // Replace 'yourUserId' with the actual userId you want to fetch
      userData = await ApiService().getUserById(widget.receiverId);
      setState(
          () {}); // Trigger a rebuild to update the UI with the fetched data
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return (isReceiver != null && userData != null)
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              toolbarHeight: 60,
              leading: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(
                      context,
                    );
                  },
                  child: Icon(
                    Icons.arrow_back,
                    size: 25,
                    color: Colors.black,
                  ),
                ),
              ),
              title: Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  CircleAvatar(
                    radius: 15,
                    backgroundImage: NetworkImage(
                        userData?['user']['profileImageUrl'] ?? ''),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    children: [
                      Text(
                        "${userData?['user']['firstName']} ${userData?['user']['lastName']}",
                        style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.black)),
                      ),
                      Text(
                        userData?['user']['Designation'] ?? '',
                        style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: Colors.black)),
                      ),
                    ],
                  ),
                ],
              ),

              //  trailing:  Text('12:31 AM',
              //    style: GoogleFonts.poppins(textStyle: const TextStyle(fontWeight: FontWeight.w400,fontSize: 12,color: Color(0xff919191))),
              //   ),
              //
              // subtitle: Text('@elezabeth',
              //  style: GoogleFonts.poppins(textStyle: const TextStyle(fontWeight: FontWeight.w500,fontSize: 12,color: Color(0xff919191))),),
            ),
            body: Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: NetworkImage(
                        userData?['user']['profileImageUrl'] ?? ''),
                  ),
                  Text(
                    "${userData?['user']['firstName']} ${userData?['user']['lastName']}",
                    style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Colors.black)),
                  ),
                  Text(
                    '@${userData?['user']['firstName']}',
                    style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.black)),
                  ),
                  if (isReceiver != null && isReceiver!)
                    TextButton(
                      onPressed: () {
                        print(
                            "Navigating profile with receiverId: ${widget.receiverId}");

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    OtherProfile(userId: widget.receiverId)));
                      },
                      style: TextButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.black26,
                        ),
                      ),
                      child: Text(
                        '   View Profile   ',
                        style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.deepPurple,
                        )),
                      ),
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: ChatService().getChatMessages(widget.chatRoomId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        } else if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              "Start the chat...",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                          );
                        } else {
                          final List<
                                  QueryDocumentSnapshot<Map<String, dynamic>>>
                              docs = snapshot.data!.docs;

                          return ListView.builder(
                            reverse: true,
                            controller: _scrollController,
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              final String senderId = doc['senderId'];
                              final String message = doc['message'];
                              isReceiver = currentUserId == doc['receiverId'];

                              final String messageType = doc['type'];
                              final String? imageUrl = doc['imageUrl'];
                              final String lastMessageStatus =
                                  doc['lastMessageStatus'];
                              final Timestamp? time = doc['timestamp'] != null
                                  ? (doc['timestamp'] is Timestamp
                                      ? doc['timestamp']
                                      : (doc['timestamp'] is DateTime
                                          ? Timestamp.fromDate(
                                              doc['timestamp'] as DateTime)
                                          : null))
                                  : Timestamp.now();
                              return Column(
                                children: [
                                  ChatMessage(
                                    text: message,
                                    isMe: senderId == currentUserId
                                        ? true
                                        : false,
                                    lastMessageStatus: lastMessageStatus,
                                    showStatus: index == 0,
                                    messageType: messageType,
                                    imageUrl: imageUrl,
                                    time: time!,
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),

                  // The container with Accept and Decline buttons
                  if (isReceiver != null && isReceiver!) ...{
                    const SizedBox(height: 46),
                    // Container with Accept and Decline buttons
                    Container(
                      padding:
                          const EdgeInsets.only(top: 20, left: 20, right: 20),
                      height: 140,
                      width: 380,
                      decoration: const BoxDecoration(
                        color: Color(0xffEEEEEE),
                        border: Border(
                          top: BorderSide(
                            color: Colors.black12,
                          ),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Show different messages based on the request status
                            if (widget.requestStatus == 'declined') ...{
                              Text(
                                'You Declined the connection request.',
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            } else ...{
                              Text(
                                '${userData?['user']['firstName']} has sent you a connection request:',
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Text(
                                'Note: Both of your profile contact details will be shared.',
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontSize: 11.65,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(
                                    height: 60,
                                    width: 155,
                                    child: TextButton(
                                      onPressed: () {
                                        print(
                                            "isRequested...${widget.requestStatus}");
                                        print("isSender...${isSender}");
                                        _declineRequest();
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        textStyle: const TextStyle(
                                          fontSize: 24,
                                        ),
                                      ),
                                      child: Text(
                                        '   Decline   ',
                                        style: GoogleFonts.poppins(
                                          textStyle: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 60,
                                    width: 155,
                                    child: TextButton(
                                      onPressed: () async {
                                        await ChatService()
                                            .acceptRequest(widget.chatRoomId);
                                        Navigator.pop(context);
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        textStyle: const TextStyle(
                                          fontSize: 24,
                                        ),
                                      ),
                                      child: Text(
                                        '   Accept   ',
                                        style: GoogleFonts.poppins(
                                          textStyle: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            }
                          ],
                        ),
                      ),
                    ),
                  },
                  if (isReceiver != null && !isReceiver!) ...{
                    if (widget.requestStatus == 'declined' && isSender!) ...{
                      const SizedBox(height: 20),
                      // Container with Accept and Decline buttons
                      Container(
                          padding: const EdgeInsets.only(
                              top: 20, left: 20, right: 20),
                          height: 100,
                          width: 380,
                          decoration: const BoxDecoration(
                            color: Color(0xffEEEEEE),
                            border: Border(
                              top: BorderSide(
                                color: Colors.black12,
                              ),
                            ),
                          ),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Show different messages based on the request status

                                Text(
                                  'Your connection request has been declined.',
                                  style: GoogleFonts.poppins(
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ]))
                    } else ...{
                      Container()
                    }
                  }
                ],
              ),
            ))
        : Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
            ),
          );
  }
}
