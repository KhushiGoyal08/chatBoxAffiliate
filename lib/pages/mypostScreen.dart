// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:omd/controller/deleteCOntroller.dart';

import 'package:omd/edit_post.dart';
import 'package:omd/home.dart';
import 'package:omd/services/api_service.dart';
import 'package:omd/show_complete_post.dart';
import 'package:omd/widgets/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPost extends StatefulWidget {
  MyPost({Key? key}) : super(key: key);
  @override
  State<MyPost> createState() => _MyPostState();
}

class _MyPostState extends State<MyPost> {
  String? userId;
  String? firstName;
  String? lastName;
  String? email;
  String? userProfileImage;
  String? flag;
  String? mobile;
  bool? isSuspended;
  bool? isEmailVerified;

  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  ApiService apiService = ApiService();
  bool isLoading = false;
  bool loadingMore = false;
  List<Post>? allPosts;
  int postsPerPage = 100; // Adjust the number of posts per page as needed
  int currentPage = 1;
  ScrollController _scrollController = ScrollController();
  final deleteController = Get.put(DeleteController());

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? '';
    firstName = prefs.getString('firstName');
    lastName = prefs.getString('lastName');
    email = prefs.getString('email');
    userProfileImage = prefs.getString('profileImageUrl') ?? '';
    flag = prefs.getString('flag') ?? '';
    mobile = prefs.getString('mobileNumber');
    getUserData();
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

  void _loadPosts() async {
    List<Post> fetchedPosts = await fetchPosts();
    setState(() {
      allPosts = fetchedPosts;
    });
  }

  Future<void> getUserData() async {
    final user = await deleteController.getUserByPhoneNumber(mobile!);
    isEmailVerified = user.user.isEmailVerified;
    isSuspended = user.user.isSuspended;
    setState(() {});
  }

  @override
  void initState() {
    _fetchUserData();
    _loadPosts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff102E44),
        leading: IconButton(
          onPressed: () {
            Get.offAll(() => Home_Screen());
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: Text(
          "My Posts",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Container(
            margin: EdgeInsets.only(top: 10),
            child: DefaultTabController(
              length: 2, // Number of tabs
              child: FutureBuilder<List<Post>>(
                  future: fetchPosts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError || snapshot.data == null) {
                      return Center(
                        child: Text('Error: ${snapshot.error ?? "No data"}'),
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
                              itemBuilder: (BuildContext context, int index) {
                                Post post = snapshot.data![index];
                                print(snapshot.data![index]);
                                print("...........${post.userId}");
                                if (post.userId == userId) {
                                  DateTime postCreationDate =
                                      DateFormat('EEE MMM dd yyyy HH:mm:ss')
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
                                          backgroundImage: userProfileImage ==
                                                  ''
                                              ? AssetImage(
                                                  'assets/account.png',
                                                )
                                              : NetworkImage(
                                                      userProfileImage ?? '')
                                                  as ImageProvider,
                                        ),
                                        trailing: PopupMenuButton<String>(
                                          onSelected: (choice) {
                                            if (choice == 'Edit') {
                                              if (isSuspended!) {
                                                Utils().toastMessage(
                                                    context,
                                                    "Your Account Has Suspended",
                                                    Colors.redAccent);
                                              } else {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            EditWPost(
                                                              post: post,
                                                            )));
                                              }
                                            } else if (choice == 'Delete') {
                                              _deletePost(post.id!, context);
                                            } else if (choice == 'Bump up') {
                                              if (daysDifference >= 1) {
                                                _bumpPost(post.id!, context);
                                              } else {
                                                Utils().toastMessage(
                                                    context,
                                                    "You can't bump the post before 24 hours",
                                                    Colors.red);
                                              }
                                            }
                                          },
                                          itemBuilder: (BuildContext context) {
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
                                              TextSpan(text: post.userName),
                                              TextSpan(
                                                text: '\t\t',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              TextSpan(
                                                text: post.flag,
                                                style: TextStyle(fontSize: 18),
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
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                  color: Color(0xff919191))),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Get.to(() => ShowCompletePost(
                                                isEmailVerified:
                                                    post.isEmailVerified ??
                                                        false,
                                                imageUrl: post.profileImageUrl,
                                                title: post.userName,
                                                description: post.postContent,
                                                postImage: post.postMediaUrl,
                                                tag: post.tag,
                                              ));
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20, right: 20, top: 10),
                                          child: (post.postContent.length > 70)
                                              ? Text(
                                                  post.postContent
                                                          .substring(0, 72) +
                                                      "......",
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
                                                )
                                              : Text(
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
                                      ),
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
            ),
          ),
        ],
      ),
    );
  }
}
