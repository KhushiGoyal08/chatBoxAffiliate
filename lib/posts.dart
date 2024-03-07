// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:omd/edit_post.dart';
import 'package:omd/edit_profile.dart';
import 'package:omd/notAcceptedProfile.dart';
import 'package:omd/other_profile.dart';
import 'package:omd/services/api_service.dart';
import 'package:omd/services/chat_service.dart';
import 'package:omd/settings.dart';
import 'package:omd/widgets/button.dart';
import 'package:omd/widgets/utils.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin_chat_page.dart';
import 'chat.dart';
import 'controller/reportController.dart';
import 'model/reportModel.dart';

class Posts extends StatefulWidget {
  const Posts({
    Key? key,
  }) : super(key: key);
  @override
  State<Posts> createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  String? userId;
  String? firstName;
  String? lastName;
  String? email;
  String? userProfileImage;
  String? flag;
  final ReportModel reportData =
      ReportModel(reportedId: '', reporterId: '', reason: '');
  final ReportController reportController = Get.put(ReportController());
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  ApiService apiService = ApiService();
  bool isLoading = false;
  bool loadingMore = false;
  List<Post>? allPosts;
  int postsPerPage = 100; // Adjust the number of posts per page as needed
  int currentPage = 1;
  ScrollController _scrollController = ScrollController();

  void _showImagePreview(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _buildImagePreviewPage(imageUrl, context),
      ),
    );
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? '';
    firstName = prefs.getString('firstName');
    lastName = prefs.getString('lastName');
    email = prefs.getString('email');
    userProfileImage = prefs.getString('profileImageUrl') ?? '';
    flag = prefs.getString('flag') ?? '';

    setState(() {}); // Trigger a rebuild to update the UI with the fetched data
  }

  void _bumpPost(String postId, context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Bump Post"),
          content: Text("Are you sure you want to bump this post?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  isLoading = true;
                });
                try {
                  var result = await ApiService().bumpPost(postId);
                  if (result['success']) {
                    ScaffoldMessenger.of(_scaffoldKey.currentContext!)
                        .showSnackBar(SnackBar(
                            content: Text("Post bumped Successfully")));
                  } else {
                    ScaffoldMessenger.of(_scaffoldKey.currentContext!)
                        .showSnackBar(
                            SnackBar(content: Text(result['message'])));
                  }
                } catch (error) {
                  ScaffoldMessenger.of(_scaffoldKey.currentContext!)
                      .showSnackBar(
                          SnackBar(content: Text("Failed to bump up Post")));
                } finally {
                  setState(() {
                    isLoading = false;
                  });
                }
              },
              child: Text("Bump"),
            ),
          ],
        );
      },
    );
  }

  void _deletePost(String postId, context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Post"),
          content: Text("Are you sure you want to delete this post?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  isLoading = true;
                });
                try {
                  var result = await ApiService().deletePost(postId);
                  if (result['success']) {
                    ScaffoldMessenger.of(_scaffoldKey.currentContext!)
                        .showSnackBar(
                      SnackBar(content: Text("Post deleted successfully")),
                    );
                  } else {
                    ScaffoldMessenger.of(_scaffoldKey.currentContext!)
                        .showSnackBar(
                      SnackBar(content: Text(result['message'])),
                    );
                  }
                } catch (error) {
                  print("Error deleting post: $error");
                  ScaffoldMessenger.of(_scaffoldKey.currentContext!)
                      .showSnackBar(
                    SnackBar(content: Text("Failed to delete post")),
                  );
                } finally {
                  setState(() {
                    isLoading = false;
                  });
                }
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<List<Post>> fetchPosts() async {
    // Add your logic to fetch posts using the ApiService
    ApiService apiService = ApiService();
    List<Post> allPosts = await apiService.getAllPosts(postsPerPage);

    // Sort the posts based on bump time and creation time
    allPosts.sort((a, b) {
      // If both posts are bumped, compare their bump times
      if (a.isbumped && b.isbumped) {
        return b.bumpTime!.compareTo(a.bumpTime!);
      }
      // If only one post is bumped or none are bumped, prioritize the new post based on creation time
      else {
        return b.createdTime!.compareTo(a.createdTime!);
      }
    });

    return allPosts;
  }

  void _loadMorePosts() async {
    if (!loadingMore) {
      setState(() {
        loadingMore = true;
      });

      int nextPage = currentPage + 1;
      int startIndex = allPosts!.length;

      // Double the number of postsPerPage each time "Load More" is tapped
      postsPerPage += 100;

      List<Post> nextPagePosts =
          await apiService.getAllPosts(postsPerPage * nextPage);

      setState(() {
        allPosts!.addAll(nextPagePosts);
        currentPage = nextPage;
        loadingMore = false;
      });

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(
              milliseconds: 500), // Adjust the duration as needed
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _loadPosts() async {
    List<Post> fetchedPosts = await fetchPosts();
    setState(() {
      allPosts = fetchedPosts;
    });
  }

  Future<void> _handleRefresh() async {
    // You can implement your logic to refresh the posts here
    // For example, call _loadPosts() to fetch new data
    _loadPosts();
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();

    _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        margin: EdgeInsets.only(top: 10),
        child: DefaultTabController(
          length: 2, // Number of tabs
          child: Column(
            children: [
              Container(
                height: 40,
                margin: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
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
                      child: Tab(text: 'All Posts'),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Tab(text: 'My Posts'),
                    )
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    FutureBuilder<List<Post>>(
                      future: fetchPosts(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError || snapshot.data == null) {
                          return Center(
                            child:
                                Text('Error: ${snapshot.error ?? "No data"}'),
                          );
                        } else if (snapshot.data!.isEmpty) {
                          return Center(
                            child: Text('No posts available.'),
                          );
                        } else {
                          return RefreshIndicator(
                            color: Color(0xff102E44),
                            onRefresh: _handleRefresh,
                            child: ListView.builder(
                                key: PageStorageKey<String>("page"),
                                shrinkWrap: true,
                                controller: _scrollController,
                                itemCount: snapshot.data!.length + 1,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == snapshot.data!.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 160, left: 20, right: 20),
                                      child: GestureDetector(
                                        onTap: () {
                                          _loadMorePosts();
                                        },
                                        child: Container(
                                            width: 320,
                                            height: 50,
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(55),
                                                topRight: Radius.circular(55),
                                                bottomLeft: Radius.circular(55),
                                                bottomRight:
                                                    Radius.circular(55),
                                              ),
                                              color: Color(0xff102E44),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                'Load More',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        255, 255, 255, 1),
                                                    fontFamily: 'Roboto',
                                                    fontSize: 18,
                                                    letterSpacing:
                                                        -0.40799999237060547,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    height: 1.2222222222222223),
                                              ),
                                            )),
                                      ),
                                    );
                                  } else {
                                    Post post = snapshot.data![index];
                                    return post.isApproved
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ListTile(
                                                  leading: CircleAvatar(
                                                    radius: 30,
                                                    backgroundImage: (post
                                                                    .profileImageUrl !=
                                                                null &&
                                                            post.profileImageUrl
                                                                .isNotEmpty)
                                                        ? NetworkImage(post
                                                                .profileImageUrl)
                                                            as ImageProvider
                                                        : AssetImage(
                                                            'assets/account.png'),
                                                  ),
                                                  trailing:
                                                      PopupMenuButton<String>(
                                                    onSelected: (choice) async {
                                                      if (choice == 'Chat'){
                                                        if (firstName!
                                                                .isEmpty ||
                                                            lastName!.isEmpty ||
                                                            email!.isEmpty) {
                                                          Utils().toastMessage(
                                                              context,
                                                              "Please fill your name and email",
                                                              Colors.red);

                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          Edit_Pro()));
                                                        } else {
                                                          if (userId! ==
                                                              post.userId) {
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
                                                              post.userId,
                                                            );
                                                            print(chatRoomId);
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            AdminChatPage(
                                                                              chatRoomId: chatRoomId,
                                                                              receiverId: post.userId,
                                                                            )));
                                                          } else {
                                                            print("Hello");
                                                            String chatRoomId =
                                                                await ChatService()
                                                                    .getChatRoomId(
                                                              userId!,
                                                              // Replace with the service provider's user ID
                                                              post.userId,
                                                            );
                                                            print(chatRoomId);
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            ChatPage(
                                                                              chatRoomId: chatRoomId,
                                                                              receiverId: post.userId,
                                                                            )));
                                                          }
                                                        }
                                                      } else if (choice ==
                                                          'Report') {


                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return Dialog(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                child:
                                                                    Container(
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.35,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            20),
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceEvenly,
                                                                      children: [
                                                                        Text(
                                                                          "Reason To Report",
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: TextStyle(
                                                                              color: Colors.black,
                                                                              fontFamily: 'Montserrat',
                                                                              fontSize: 24,
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                        Icon(
                                                                            Icons
                                                                                .report,
                                                                            color:
                                                                                Colors.redAccent,
                                                                            size: MediaQuery.of(context).size.height * 0.07),
                                                                        TextFormField(
                                                                          onChanged:
                                                                              (val) {
                                                                            reportData.reason =
                                                                                val;
                                                                          },
                                                                        ),
                                                                        ElevatedButton(
                                                                            onPressed:
                                                                                () {

                                                                                if (userId! == post.userId) {
                                                                                  Utils().toastMessage(context, "You cannot Report Yourself", Colors.red);
                                                                                } else {
                                                                               if(reportData.reason!='' && reportData.reason.isNotEmpty){
                                                                                 reportController.reportUser(userId!, post.userId, reportData.reason);
                                                                                 print(reportData.reason);
                                                                                 Navigator.pop(context);
                                                                               }
                                                                               else{
                                                                                 Utils().toastMessage(
                                                                                     context,
                                                                                     "Please Report Something",
                                                                                     Colors.red);
                                                                               }
                                                                                }

                                                                            },
                                                                            style:
                                                                                ElevatedButton.styleFrom(
                                                                              backgroundColor: Color(0xff102E44),
                                                                            ),
                                                                            child: Text(
                                                                              "Report User",
                                                                              style: TextStyle(
                                                                                color: Color.fromRGBO(255, 255, 255, 1),
                                                                                fontFamily: 'Montserrat',
                                                                                fontSize: 17,
                                                                              ),
                                                                            ))
                                                                        // Button(onPressed: (){
                                                                        //
                                                                        // }, icon: Icon(Icons.check_circle,color: Colors.white,), text: "Yes,I agree")
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            });
                                                      }
                                                    },
                                                    itemBuilder:
                                                        (BuildContext context) {
                                                      List<
                                                              PopupMenuEntry<
                                                                  String>>
                                                          menuItems = [
                                                        const PopupMenuItem<
                                                            String>(
                                                          value: 'Chat',
                                                          child:
                                                              Text('Chat'),
                                                        ),
                                                        const PopupMenuItem<
                                                            String>(
                                                          value: 'Report',
                                                          child: Text('Report'),
                                                        ),
                                                      ];

                                                      // Add the 'Bump up' option only if the post is 2 days old

                                                      return menuItems;
                                                    },
                                                  ),
                                                  title: GestureDetector(
                                                    onTap: () async {
                                                      bool isRequestAccepted =
                                                          await ChatService()
                                                              .checkIsRequestedAccepted(
                                                                  post.userId,
                                                                  userId!);
                                                      if (isRequestAccepted) {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                OtherProfile(
                                                              userId:
                                                                  post.userId,
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
                                                                  post.userId,
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child: Text.rich(
                                                      TextSpan(
                                                        children: [
                                                          TextSpan(
                                                              text: post
                                                                  .userName),
                                                          TextSpan(
                                                            text: '\t\t',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          TextSpan(
                                                            text: post.flag,
                                                            style: TextStyle(
                                                                fontSize: 18),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 20,
                                                  right: 20,
                                                ),
                                                child: Text(
                                                  post.postContent,
                                                  textAlign: TextAlign.left,
                                                  style: GoogleFonts.poppins(
                                                    textStyle: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 12,
                                                      color: Color(0xff5A5A5A),
                                                      height: 1.8,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              if (post.postMediaUrl != null &&
                                                  post.postMediaUrl
                                                      .isNotEmpty) ...{
                                                Padding(
                                                  padding: EdgeInsets.all(10),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      _showImagePreview(context,
                                                          post.postMediaUrl);
                                                    },
                                                    child: Container(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 10),
                                                      height: 200,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          Image.network(
                                                            post.postMediaUrl,
                                                            fit: BoxFit.cover,
                                                            width:
                                                                double.infinity,
                                                            height:
                                                                double.infinity,
                                                            loadingBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    Widget
                                                                        child,
                                                                    ImageChunkEvent?
                                                                        loadingProgress) {
                                                              if (loadingProgress ==
                                                                  null) {
                                                                return child;
                                                              } else {
                                                                return Center(
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                    value: loadingProgress.expectedTotalBytes !=
                                                                            null
                                                                        ? loadingProgress.cumulativeBytesLoaded /
                                                                            (loadingProgress.expectedTotalBytes ??
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
                                          )
                                        : Container();
                                  }
                                }),
                          );
                        }
                      },
                    ),
                    FutureBuilder<List<Post>>(
                        future: fetchPosts(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError ||
                              snapshot.data == null) {
                            return Center(
                              child:
                                  Text('Error: ${snapshot.error ?? "No data"}'),
                            );
                          } else if (snapshot.data!.isEmpty) {
                            return Center(
                              child: Text('No posts available.'),
                            );
                          } else {
                            return isLoading
                                ? Center(child: CircularProgressIndicator())
                                : ListView.builder(
                                    itemCount: snapshot.data!.length,
                                    shrinkWrap: true,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      Post post = snapshot.data![index];
                                      print(snapshot.data![index]);
                                      print("...........${post.userId}");
                                      if (post.userId == userId) {
                                        DateTime postCreationDate = DateFormat(
                                                'EEE MMM dd yyyy HH:mm:ss')
                                            .parse(post.postCreated);

                                        DateTime currentDate = DateTime.now();
                                        int daysDifference = currentDate
                                            .difference(postCreationDate)
                                            .inDays;
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ListTile(
                                              leading: CircleAvatar(
                                                radius: 30,
                                                backgroundImage:
                                                    userProfileImage == ''
                                                        ? AssetImage(
                                                            'assets/account.png',
                                                          )
                                                        : NetworkImage(
                                                                userProfileImage ??
                                                                    '')
                                                            as ImageProvider,
                                              ),
                                              trailing: PopupMenuButton<String>(
                                                onSelected: (choice) {
                                                  if (choice == 'Edit') {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    EditWPost(
                                                                      post:
                                                                          post,
                                                                    )));
                                                  } else if (choice ==
                                                      'Delete') {
                                                    _deletePost(
                                                        post.id!, context);
                                                  } else if (choice ==
                                                      'Bump up') {
                                                    if (daysDifference >= 1) {
                                                      _bumpPost(
                                                          post.id!, context);
                                                    } else {
                                                      Utils().toastMessage(
                                                          context,
                                                          "You can't bump the post before 24 hours",
                                                          Colors.red);
                                                    }
                                                  }
                                                },
                                                itemBuilder:
                                                    (BuildContext context) {
                                                  List<PopupMenuEntry<String>>
                                                      menuItems = [
                                                    const PopupMenuItem<String>(
                                                      value: 'Edit',
                                                      child: Text('Edit'),
                                                    ),
                                                    const PopupMenuItem<String>(
                                                      value: 'Delete',
                                                      child: Text('Delete'),
                                                    ),
                                                    const PopupMenuItem<String>(
                                                      value: 'Bump up',
                                                      child: Text('Bump up'),
                                                    ),
                                                  ];

                                                  // Add the 'Bump up' option only if the post is 2 days old

                                                  return menuItems;
                                                },
                                              ),
                                              title: Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                        text: post.userName),
                                                    TextSpan(
                                                      text: '\t\t',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    TextSpan(
                                                      text: post.flag,
                                                      style: TextStyle(
                                                          fontSize: 18),
                                                    ),
                                                  ],
                                                ),

                                                //  style: TextStyle(fontSize: 20,fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                                              ),
                                              subtitle: Text(
                                                post.isApproved
                                                    ? "Status: Approved"
                                                    : (post.underApproval
                                                        ? "Status: Under Approval"
                                                        : "Status: Disapproved"),
                                                style: GoogleFonts.poppins(
                                                    textStyle: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xff919191))),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20, right: 20),
                                              child: Text(
                                                post.postContent,
                                                style: GoogleFonts.poppins(
                                                    textStyle: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xff5A5A5A),
                                                        height: 1.8)),
                                              ),
                                            ),
                                            if (post.postMediaUrl != null &&
                                                post.postMediaUrl
                                                    .isNotEmpty) ...{
                                              Padding(
                                                padding: EdgeInsets.all(10),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    _showImagePreview(context,
                                                        post.postMediaUrl);
                                                  },
                                                  child: Container(
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 10),
                                                    height:
                                                        200, // Adjust the height based on your design
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Stack(
                                                      children: [
                                                        Image.network(
                                                          post.postMediaUrl,
                                                          fit: BoxFit.cover,
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              double.infinity,
                                                          loadingBuilder:
                                                              (BuildContext
                                                                      context,
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
                                                                          (loadingProgress.expectedTotalBytes ??
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
                                              )
                                            },
                                            SizedBox(
                                              height: 10,
                                            ),
                                            const Divider(),
                                          ],
                                        );
                                      } else {
                                        return Container();
                                      }
                                    });
                          }
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//     );
//  else if (loadingMore) {
//     // This is the loading indicator during load more
//     return Center(
//       child: CircularProgressIndicator(),
//     );
//   } else {
//     // This is the "Load More" button
//     return Padding(
//       padding: const EdgeInsets.only(
//           bottom: 160.0, left: 20, right: 20),
//       child: GestureDetector(
//         onTap: () {
//           _loadMorePosts();
//         },
//         child: Container(
//             width: 320,
//             height: 50,
//             decoration: const BoxDecoration(
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(55),
//                 topRight: Radius.circular(55),
//                 bottomLeft: Radius.circular(55),
//                 bottomRight: Radius.circular(55),
//               ),
//               color: Color(0xff102E44),
//             ),
//             child: const Center(
//               child: Text(
//                 'Load More',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     color: Color.fromRGBO(
//                         255, 255, 255, 1),
//                     fontFamily: 'Roboto',
//                     fontSize: 18,
//                     letterSpacing:
//                         -0.40799999237060547,
//                     fontWeight: FontWeight.normal,
//                     height: 1.2222222222222223),
//               ),
//             )),
//       ),
//     );
//   }

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


