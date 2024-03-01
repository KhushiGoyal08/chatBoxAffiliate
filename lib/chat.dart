// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omd/msgs_requests.dart';
import 'package:omd/previewImage.dart';
import 'package:omd/services/api_service.dart';
import 'package:omd/services/chat_service.dart';
import 'package:omd/services/notification_service.dart';
import 'package:omd/widgets/chat_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_field.dart';

class ChatPage extends StatefulWidget {
  String chatRoomId;

  String receiverId;

  ChatPage({
    Key? key,
    required this.chatRoomId,
    required this.receiverId,
  }) : super(key: key);
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GlobalKey<_ChatPageState> chatPageKey = GlobalKey<_ChatPageState>();
  TextEditingController chatMessage = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;
  bool _isFirstMessageSent = false;

  bool _isUploading = false;

  bool _requestContainerShown = false;

  String? currentUserId;
  String? firstName;
  String? lastName;
  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getString('userId') ?? '';
    firstName = prefs.getString('firstName') ?? '';
    lastName = prefs.getString('lastName') ?? '';

    setState(() {}); // Trigger a rebuild to update the UI with the fetched data
  }

  Future<void> _showImagePreview(String imagePath) async {
    final shouldSendImage = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviewImagePage(imagePath: imagePath),
      ),
    );

    if (shouldSendImage == true) {
      _sendImage(imagePath); // Send the image
    }
  }

  Future<void> _sendImage(String imagePath) async {
    setState(() {
      _isUploading = true;
    });
    // If an image is selected, upload it and send as an image message
    try {
      final imageUrl = await ChatService().uploadImage(
        currentUserId!,
        imagePath,
        widget.chatRoomId,
      );

      await ChatService().sendMessage(
        currentUserId!,
        widget.chatRoomId,
        widget.receiverId,
        "", // You may want to send an empty text for image messages
        'image', // Set message type to 'image'
        imageUrl: imageUrl, // Pass the imageUrl
      );

      NotificationService().sendNotification(
          userData?['token'],
          "${firstName} ${lastName}",
          "${firstName} ${lastName} sent you an Image",
          currentUserId!,
          widget.chatRoomId);

      setState(() {
        _selectedImage = null; // Clear the selected image after sending
      });
    } catch (error) {
      print("Error sending image: $error");
      // Handle the error as needed
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Map<String, dynamic>? userData;
  Future<void> _fetchOtherUserData() async {
    try {
      final result = await ApiService().getUserById(widget.receiverId);

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

  String? _isChatRequestAccepted;
  @override
  void initState() {
    _fetchUserData();
    _fetchOtherUserData();

    final userIds = widget.chatRoomId.split('_');
    //receiverId = userIds.firstWhere((id) => id != currentUserId);
    // TODO: implement initState
    ChatService()
        .markLatestMessageAsSeen(widget.chatRoomId, currentUserId ?? '');
    ChatService().resetUnreadCount(widget.chatRoomId, currentUserId ?? '');
    _checkChatRequestStatus();
    super.initState();
  }

  bool _initialized = false;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (!_initialized) {
      _fetchUserData();
      // Initialize isFirstMessageSent based on whether there are messages
      _isFirstMessageSent = await _checkIfFirstMessageSent();
      _initialized = true;
    }
  }

  Future<bool> _checkIfFirstMessageSent() async {
    try {
      // Check if there are any existing messages in the chat
      QuerySnapshot<Map<String, dynamic>> messagesSnapshot =
          await FirebaseFirestore.instance
              .collection('chats')
              .doc(widget.chatRoomId)
              .collection('messages')
              .limit(1)
              .get();

      return messagesSnapshot.docs.isNotEmpty;
    } catch (error) {
      print("Error checking if it's the first message: $error");
      return false;
    }
  }

  Future<void> _checkChatRequestStatus() async {
    String isChatRequestAccepted =
        await ChatService().isChatRequestAccepted(widget.chatRoomId);

    setState(() {
      _isChatRequestAccepted = isChatRequestAccepted;
    });

    if (isChatRequestAccepted == 'accepted' && !_requestContainerShown) {
      setState(() {
        _requestContainerShown = true;
      });
      _buildRequestStatusContainer();
    }

    // If the request is pending, you can show the container
    // and optionally disable the input field.
    // If the request is accepted, you can proceed with your current logic.
  }

  Future<void> _pickImage() async {
    final pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      await _cropAndCompressImage(pickedImage.path);
    }
  }

  Future<void> _cropAndCompressImage(String imagePath) async {
    final croppedFile = await ImageCropper()
        .cropImage(sourcePath: imagePath, aspectRatioPresets: [
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9,
    ], uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Color(0xff102E44),
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
      ),
    ]);
    IOSUiSettings(
      title: 'Cropper',
    );

    if (croppedFile != null) {
      final dir = await path_provider.getTemporaryDirectory();
      final targetPath = '${dir.absolute.path}/temp.jpg';
      // Compress the cropped image before sending
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        croppedFile.path,
        imagePath, // Overwrite the original image
        quality: 80,
        minHeight: 720,
        minWidth: 720,
      );
      final data = await compressedFile!.readAsBytes();
      final newKb = data.length / 1024;
      final newMb = newKb / 1024;

      if (kDebugMode) {
        print('compressed image size:' + newMb.toString());
      }

      // Now, you can use the compressedFile for further processing or sending
      // For example, send the image using `_sendImage(compressedFile.path);`
      await _sendImage(compressedFile!.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return userData != null
        ? Scaffold(
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
              title: Text(
                  "${userData?['firstName'] ?? ''} ${userData?['lastName'] ?? ''}",
                  style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.white))),
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: ChatService().getChatMessages(widget.chatRoomId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      } else if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            currentUserId != '658c582ff1bc8978d2300823'
                                ? "Please Send the Request Message..."
                                : "Start the Chat...",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                        );
                      } else {
                        final List<QueryDocumentSnapshot<Map<String, dynamic>>>
                            docs = snapshot.data!.docs;
                        ChatService().resetUnreadCount(
                            widget.chatRoomId, currentUserId!);
                        ChatService().markLatestMessageAsSeen(
                          widget.chatRoomId,
                          currentUserId!,
                        );

                        // Check if the chat request is accepted and it's the first message
                        if (_isChatRequestAccepted == 'accepted' &&
                            !_isFirstMessageSent) {
                          return ListView.builder(
                            reverse: true,
                            controller: _scrollController,
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              final String senderId = doc['senderId'];
                              final String message = doc['message'];
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
                                    isMe: senderId == currentUserId,
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
                        } else {
                          return ListView.builder(
                            reverse: true,
                            controller: _scrollController,
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              final String senderId = doc['senderId'];
                              final String message = doc['message'];
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
                                    isMe: senderId == currentUserId,
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
                      }
                    },
                  ),
                ),
                if (_isChatRequestAccepted == 'pending')
                  _buildRequestStatusContainer()
                else if (_isChatRequestAccepted == 'accepted' ||
                    _isChatRequestAccepted == '' && !_isFirstMessageSent)
                  _buildInputField(),
              ],
            ),
          )
        : Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
  }

  Widget _buildRequestStatusContainer() {
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.receiverId != currentUserId
                ? 'Chat request is Pending.'
                : "Chat request is Pending.",
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Colors.red,
              ),
            ),
          ),
          Text(
            'Once the request is accepted, You can continue chatting.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return _isUploading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Container(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                // IconButton(onPressed: () {}, icon: Icon(Icons.file_open)),
                Expanded(
                    child: ChatField(
                  controller: chatMessage,
                  onPressed: () {
                    _pickImage();
                  },
                  hintText: "Write a Message....",
                )),
                _isUploading
                    ? SizedBox(
                        child: Center(child: CircularProgressIndicator()),
                        height: 10.0,
                        width: 10.0,
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.send,
                          color: Color(0xff102E44),
                        ),
                        onPressed: () {
                          _sendMessage();
                        },
                      ),
              ],
            ),
          );
  }

  Future<void> _sendMessage() async {
    // Check if the chat request has been accepted
    String ischatRequestAccepted =
        await ChatService().isChatRequestAccepted(widget.chatRoomId);
    if (ischatRequestAccepted == 'accepted' || await _isFirstMessage()) {
      // If the request is accepted, allow sending the message
      if (chatMessage.text.isNotEmpty || _selectedImage != null) {
        final messageText = chatMessage.text.trim();

        // Clear the text field immediately
        chatMessage.clear();
        if (!_isFirstMessageSent) {
          setState(() {
            _isFirstMessageSent = true;
          });
        }

        if (_selectedImage != null) {
          setState(() {
            _isUploading = true; // Set to true before starting the upload
          });
          // If an image is selected, upload it and send as an image message
          try {
            final imageUrl = await ChatService().uploadImage(
              currentUserId!,
              _selectedImage!.path,
              widget.chatRoomId,
            );

            await ChatService().sendMessage(
              currentUserId!,
              widget.chatRoomId,
              widget.receiverId,
              messageText,
              'image', // Set message type to 'image'
              imageUrl: imageUrl, // Pass the imageUrl
            );

            setState(() {
              _selectedImage = null; // Clear the selected image after sending
            });
          } finally {
            setState(() {
              _isUploading = false;
            });
          }
        } else {
          // If no image is selected, send as a text message
          await ChatService().sendMessage(
            currentUserId!,
            widget.chatRoomId,
            widget.receiverId,
            messageText,
            'text', // Set message type to 'text'
          );
          NotificationService().sendNotification(
              userData?['token'],
              "${firstName} ${lastName}",
              messageText,
              currentUserId!,
              widget.chatRoomId);
        }
      }
      _checkChatRequestStatus();
    } else {
      _buildRequestStatusContainer();
    }
  }

  _isFirstMessage() async {
    try {
      // Check if there are any existing messages in the chat
      QuerySnapshot<Map<String, dynamic>> messagesSnapshot =
          await FirebaseFirestore.instance
              .collection('chats')
              .doc(widget.chatRoomId)
              .collection('messages')
              .limit(1)
              .get();

      return messagesSnapshot.docs.isEmpty; // Return true if no messages exist
    } catch (error) {
      print("Error checking if it's the first message: $error");
      return false; // Return false in case of an error
    }
  }
}
