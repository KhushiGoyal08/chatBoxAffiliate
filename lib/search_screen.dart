import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omd/edit_profile.dart';
import 'package:omd/services/api_service.dart';
import 'package:omd/services/chat_service.dart';
import 'package:omd/settings.dart';
import 'package:omd/widgets/my_textfield.dart';
import 'package:omd/widgets/utils.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin_chat_page.dart';
import 'chat.dart';
import 'notAcceptedProfile.dart';
import 'other_profile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final searchController = TextEditingController();
  String? userId;
  String? lastName;
  String? firstName;
  String? email;
  List<Map<String, dynamic>> searchResults = [];
  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? '';
    firstName = prefs.getString('firstName') ?? '';
    lastName = prefs.getString('lastName') ?? '';
    email = prefs.getString('email') ?? '';
    setState(() {}); // Trigger a rebuild to update the UI with the fetched data
  }

  void performSearch(String query) async {
    try {
      final Map<String, dynamic> result = await ApiService().searchPosts(query);

      if (result['success']) {
        setState(() {
          searchResults = List<Map<String, dynamic>>.from(
            result['searchResults'],
          );
        });
      }
      if (searchResults.isEmpty) {
        // Show a message using SnackBar or Flushbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No Post found"),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        print(result['message']);
      }
    } catch (error) {
      // Handle errors during the search operation
      // You can show an error message or perform other actions
      print('Error performing search: $error');
    }
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _buildImagePreviewPage(imageUrl, context),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Image.asset(
          'assets/logo-black.png',
          height: 150,
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: searchController,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                    onPressed: () {
                      performSearch(searchController.text);
                    },
                    icon: Icon(
                      Icons.search,
                      color: Colors.black,
                    )),
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
                hintText: "Enter text to Search",
                hintStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    color: Colors.black,
                    letterSpacing: -0.33,
                    fontFamily: 'Montserrat'),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
                child: FutureBuilder(
                    future: ApiService().searchPosts(searchController.text),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Display a loading indicator while waiting for the result
                        return Center(child: CircularProgressIndicator());
                      } else {
                        if (snapshot.hasError) {
                          // Handle errors
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else {
                          // Display the search results
                          return ListView.builder(
                              itemCount: searchResults.length,
                              itemBuilder: (context, index) {
                                final result = searchResults[index];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      leading: CircleAvatar(
                                        radius: 30,
                                        backgroundImage:
                                            result['profileImageUrl'] == ''
                                                ? AssetImage(
                                                    'assets/account.png',
                                                  )
                                                : NetworkImage(result[
                                                            'profileImageUrl']
                                                        .toString())
                                                    as ImageProvider,
                                      ),
                                      trailing: PopupMenuButton<String>(
                                        onSelected: (choice) async {
                                          if (choice == 'Profile Details') {
                                            bool isRequestAccepted =
                                                await ChatService()
                                                    .checkIsRequestedAccepted(
                                                        result['userId'],
                                                        userId!);
                                            if (isRequestAccepted) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      OtherProfile(
                                                    userId: result['userId'],
                                                  ),
                                                ),
                                              );
                                            } else {
                                              // Show a message indicating that the user has not accepted your request yet
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      NotAcceptedProfile(
                                                    otherUserId:
                                                        result['userId']
                                                            .toString(),
                                                  ),
                                                ),
                                              );
                                            }
                                          } else if (choice ==
                                              'Chat with User') {
                                            print("Heloo");
                                          }
                                        },
                                        itemBuilder: (BuildContext context1) {
                                          return [
                                            const PopupMenuItem<String>(
                                              value: 'Profile Details',
                                              child: Text('Profile Details'),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'Chat with user',
                                              child: Text('Chat with user'),
                                              onTap: () async {
                                                if (firstName!.isEmpty ||
                                                    lastName!.isEmpty ||
                                                    email!.isEmpty) {
                                                  Utils().toastMessage(
                                                      context1,
                                                      "Please fill your name and email",
                                                      Colors.red);

                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Edit_Pro()));
                                                } else {
                                                  if (userId! ==
                                                      result['userId']) {
                                                    Utils().toastMessage(
                                                        context,
                                                        "You cannot chat with yourself",
                                                        Colors.red);
                                                  } else if (userId! ==
                                                      '658c582ff1bc8978d2300823') {
                                                    String chatRoomId =
                                                        await ChatService()
                                                            .getChatRoomId(
                                                      userId!,
                                                      // Replace with the service provider's user ID
                                                      result['userId'],
                                                    );
                                                    print(chatRoomId);
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                AdminChatPage(
                                                                  chatRoomId:
                                                                      chatRoomId,
                                                                  receiverId:
                                                                      result[
                                                                          'userId'],
                                                                )));
                                                  } else {
                                                    print("Hello");
                                                    String chatRoomId =
                                                        await ChatService()
                                                            .getChatRoomId(
                                                      userId!,
                                                      // Replace with the service provider's user ID
                                                      result['userId'],
                                                    );
                                                    print(chatRoomId);
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    ChatPage(
                                                                      chatRoomId:
                                                                          chatRoomId,
                                                                      receiverId:
                                                                          result[
                                                                              'userId'],
                                                                    )));
                                                  }
                                                }
                                              },
                                            ),
                                          ];
                                        },
                                      ),
                                      title: Text(
                                        result['userName'],
                                        style: GoogleFonts.poppins(
                                          textStyle: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      subtitle: Text(
                                        "@${result['userName'].split(" ").first}",
                                        style: GoogleFonts.poppins(
                                          textStyle: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                            color: Color(0xff919191),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                      ),
                                      child: Text(
                                        result['postContent'],
                                        textAlign: TextAlign.left,
                                        style: GoogleFonts.poppins(
                                          textStyle: const TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                            color: Color(0xff5A5A5A),
                                            height: 1.8,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (result['postMediaUrl'] != null &&
                                        result['postMediaUrl'] is String &&
                                        result['postMediaUrl']
                                            .toString()
                                            .isNotEmpty) ...{
                                      Padding(
                                        padding: EdgeInsets.all(10),
                                        child: GestureDetector(
                                          onTap: () {
                                            _showImagePreview(
                                                context,
                                                result['postMediaUrl']
                                                    .toString());
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            height: 200,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Stack(
                                              children: [
                                                Image.network(
                                                  result['postMediaUrl']
                                                      .toString(),
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  loadingBuilder:
                                                      (BuildContext context,
                                                          Widget child,
                                                          ImageChunkEvent?
                                                              loadingProgress) {
                                                    if (loadingProgress ==
                                                        null) {
                                                      return child;
                                                    } else {
                                                      return Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          value: loadingProgress
                                                                      .expectedTotalBytes !=
                                                                  null
                                                              ? loadingProgress
                                                                      .cumulativeBytesLoaded /
                                                                  (loadingProgress
                                                                          .expectedTotalBytes ??
                                                                      1)
                                                              : null,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    },
                                    SizedBox(
                                      height: 10,
                                    ),
                                    const Divider(),
                                  ],
                                );
                              });
                        }
                      }
                    }))
          ],
        ),
      ),
    );
  }
}

Widget _buildImagePreviewPage(String imageUrl, context) {
  return Scaffold(
    backgroundColor: Colors.black12,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: const Icon(
            Icons.cancel,
            color: Colors.white,
          ),
        ),
      ),
      centerTitle: true,
    ),
    body: PhotoViewGallery.builder(
      itemCount: 1,
      builder: (context, index) {
        return PhotoViewGalleryPageOptions(
          imageProvider: NetworkImage(imageUrl),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
        );
      },
      scrollPhysics: BouncingScrollPhysics(),
      backgroundDecoration: BoxDecoration(
        color: Colors.black,
      ),
      pageController: PageController(),
      onPageChanged: (index) {},
    ),
  );
}
