import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isMe;
  final String? lastMessageStatus;

  final bool showStatus;
  final Timestamp time;

  final String? imageUrl; // Add imageUrl to handle image messages
  final String? messageType;
  ChatMessage({
    required this.text,
    required this.isMe,
    this.lastMessageStatus,
    required this.showStatus,
    required this.time,
    this.imageUrl,
    this.messageType,
  });
  String _formatTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedTime = DateFormat.jm().format(dateTime);
    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (messageType == 'image' && imageUrl != null)
          GestureDetector(
            onTap: () {
              _showImagePreview(context, imageUrl!);
            },
            child: Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: isMe
                    ? EdgeInsets.only(top: 8.0, bottom: 8, right: 8)
                    : EdgeInsets.only(top: 8.0, bottom: 8, left: 8),
                child: Stack(
                  children: [
                    Container(
                      width: 250, // Adjust the width as needed
                      height: 200, // Adjust the height as needed
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 3,
                            spreadRadius: 3,
                            color: Colors.black12,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // Ensure consistent border radius
                      ),
                      child: Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      ),
                    ),
                    Container(
                      height: 200,
                      width: 250,
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          _formatTime(time),
                          style: TextStyle(color: Colors.white60, fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (messageType == 'text')
          ChatBubble(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              clipper: isMe
                  ? ChatBubbleClipper4(type: BubbleType.sendBubble)
                  : ChatBubbleClipper4(type: BubbleType.receiverBubble),
              margin: EdgeInsets.only(top: 20),
              backGroundColor: isMe ? Color(0xff102E44) : Colors.grey[300],
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: RichText(
                  text: TextSpan(
                    text: text,
                    style: GoogleFonts.poppins(
                      color: isMe ? Colors.white : Colors.black54,
                      fontSize: 15,
                    ),
                    children: <TextSpan>[
                      if (time != null) ...{
                        TextSpan(
                            text: "\t\t${_formatTime(time)}",
                            style: GoogleFonts.poppins(fontSize: 8)),
                      }
                    ],
                  ),
                ),
              )
              // ClipPath(
              //   clipper: isMe
              //       ? LowerNipMessageClipper(MessageType.send)
              //       : LowerNipMessageClipper(MessageType.receive),
              //   child: Container(
              //     margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              //     padding: EdgeInsets.all(10),
              //     decoration: BoxDecoration(
              //       color: isMe ? greenColor.withOpacity(0.8) : Colors.grey[300],
              //     ),
              //     child: RichText(
              //       text: TextSpan(
              //         text: text,
              //         style: GoogleFonts.poppins(
              //           color: isMe ? Colors.white : Colors.black54,
              //           fontSize: 15,
              //         ),
              //         children: <TextSpan>[
              //           if (time != null) ...{
              //             TextSpan(
              //                 text: "\t\t${_formatTime(time)}",
              //                 style: GoogleFonts.poppins(fontSize: 8)),
              //           }
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              ),
        // if (showStatus && lastMessageStatus != null)
        //   isMe
        //       ? Align(
        //           alignment: Alignment.centerRight,
        //           child: Padding(
        //             padding: const EdgeInsets.only(bottom: 8.0, right: 8),
        //             child: lastMessageStatus == "Seen"
        //                 ? Icon(
        //                     Icons.done_all,
        //                     color: Colors.blue,
        //                     size: 20,
        //                   )
        //                 : Container(),
        //           ),
        //         )
        //       : Container(),
      ],
    );
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _buildImagePreviewPage(imageUrl, context),
      ),
    );
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
}
