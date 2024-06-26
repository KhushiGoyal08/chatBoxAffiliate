import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:info_popup/info_popup.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ShowCompletePost extends StatelessWidget {
  final String? imageUrl;
  final String? title;
  final String? description;
  final String? postImage;
  final String? tag;
  final bool? isEmailVerified;

  const ShowCompletePost(
      {super.key,
      required this.imageUrl,
      required this.title,
      required this.isEmailVerified,
      required this.description,
      required this.postImage,
      required this.tag});

  void _showImagePreview(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _buildImagePreviewPage(imageUrl, context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff102E44),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Post",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
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
                  SizedBox(width: 10),
                  (isEmailVerified! == true)
                      ? const InfoPopupWidget(
                          contentTitle: "Email and Phone Number is Verified .",
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                        )
                      : SizedBox.shrink(),
                  Spacer(),
                  (tag != 'blank')
                      ? Container(
                          decoration: BoxDecoration(
                              color: (tag == 'buy')
                                  ? Colors.green
                                  : Colors.redAccent,
                              borderRadius: BorderRadius.circular(5)),
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: (tag == 'buy')
                              ? Text(
                                  "Buyer",
                                  style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                )
                              : Text(
                                  "Seller",
                                  style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ))
                      : Container(),
                ],
              ),

              SizedBox(height: 16),

              GestureDetector(
                child: Text(
                  description.toString(),
                  maxLines: null,
                  style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Color(0xff5A5A5A),
                          height: 2.5)),
                ),
              ),
              //  maxLines: 3,
              //  overflow: TextOverflow.ellipsis,
              //   ),
              postImage != null
                  ? Padding(
                      padding: EdgeInsets.all(8),
                      child: GestureDetector(
                        onTap: () {
                          _showImagePreview(context, postImage!);
                        },
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          child: CachedNetworkImage(
                              imageUrl: postImage!,
                              placeholder: (context, url) =>
                                  Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => Container(),
                              fit: BoxFit.fill),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
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
