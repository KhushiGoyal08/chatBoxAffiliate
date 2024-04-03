import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omd/services/api_service.dart';
import 'package:omd/show_complete_post.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomContainer extends StatelessWidget {
  final String? imageUrl;
  final String? title;
  final String? description;
  final String? postImage;

  CustomContainer({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.postImage,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: imageUrl == ''
                      ? AssetImage(
                          'assets/account.png',
                        )
                      : NetworkImage(imageUrl ?? '') as ImageProvider,
                ),
                SizedBox(width: 10),
                Text(title.toString(), style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 10),

            Text(
              description.toString(),
              maxLines: null,
              style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Color(0xff5A5A5A),
                      height: 2.5)),
            ),

            //  maxLines: 3,
            //  overflow: TextOverflow.ellipsis,
            //   ),
            // Padding(
            //   padding: EdgeInsets.all(10),
            //   child: Container(
            //     margin: const EdgeInsets.symmetric(vertical: 10),
            //     height: 200, // Adjust the height based on your design
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(8),
            //       image: DecorationImage(
            //         image: NetworkImage(postUrl!),
            //         fit: BoxFit.cover,
            //       ),
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}

class SwiperDemo extends StatefulWidget {
  @override
  State<SwiperDemo> createState() => _SwiperDemoState();
}

class _SwiperDemoState extends State<SwiperDemo> {
  String? userProfileImage;
  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    userProfileImage = prefs.getString('profileImageUrl') ?? '';

    setState(() {}); // Trigger a rebuild to update the UI with the fetched data
  }

  List<Map<String, dynamic>> data = [];

  Future<void> fetchPinnedPosts() async {
    try {
      // Call the getPinnedPosts function from ApiService
      List<Map<String, dynamic>> pinnedPosts =
          await ApiService().getPinnedPosts();
      print(pinnedPosts);

      setState(() {
        data = pinnedPosts;
      });
    } catch (error) {
      // Handle the error, e.g., show an error message
      print('Error fetching pinned posts: $error');
    }
  }

  Future<void> _handleRefresh() async {
    // You can implement your logic to refresh the posts here
    // For example, call _loadPosts() to fetch new data
    fetchPinnedPosts();
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    fetchPinnedPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xffEEEEEE),
      height: 200,
      child: FutureBuilder(
        future: ApiService().getPinnedPosts(),
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
            return Swiper(
              duration: 600,
              autoplay: true,
              // pagination: SwiperPagination(
              // builder:
              // DotSwiperPaginationBuilder(
              //     color: Color(0xffD2D2D2), activeColor: Color(0xff919191)),
              // margin: EdgeInsets.only(right: 35, top: 35),
              // alignment: Alignment.topRight,
              // ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final data = snapshot.data![index];
                return GestureDetector(
                  onTap: () {
                    Get.to(() => ShowCompletePost(
                          imageUrl: data['profileImageUrl'] ?? '',
                          title: data['userName'],
                          description: data['postContent'],
                          postImage: data['postMediaUrl'],
                          tag: 'blank',
                        ));
                  },
                  child: CustomContainer(
                    imageUrl: data['profileImageUrl'] ?? '',
                    title: data['userName'],
                    description: data['postContent'],
                    postImage: data['postMediaUrl'],
                  ),
                );
              },
              controller: SwiperController(),
              scrollDirection: Axis.horizontal,
            );
          }
        },
      ),
    );
  }
}
