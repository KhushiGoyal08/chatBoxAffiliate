import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:omd/home.dart';
import 'package:http/http.dart' as http;
import 'package:omd/services/api_service.dart';
import 'package:path_provider/path_provider.dart';

class EditWPost extends StatefulWidget {
  final Post post;
  const EditWPost({Key? key, required this.post}) : super(key: key);

  @override
  State<EditWPost> createState() => _EditWPostState();
}

class _EditWPostState extends State<EditWPost> {
  File? _image;
  bool isLoading = false;
  XFile? _selectImage;
  List<String> all_tag = ['blank', 'buy', 'sell'];
  final picker = ImagePicker();
  List<bool> _isSelected = [true, false, false];

  bool isAddingPost = false;
  String tag = 'blank';
  Future imagePickerFromGallery() async {
    _selectImage = (await picker.pickImage(source: ImageSource.gallery))!;

    // final bytes = await _selectImage!.readAsBytes();
    // final kb = bytes.length / 1024;
    // final mb = kb / 1024;

    // if (kDebugMode) {
    //   print('original image size:' + mb.toString());
    // }

    await _cropImage();
  }

  Future imagePickerFromCamera() async {
    _selectImage = (await picker.pickImage(source: ImageSource.camera))!;

    // final bytes = await _selectImage!.readAsBytes();
    // final kb = bytes.length / 1024;
    // final mb = kb / 1024;

    // if (kDebugMode) {
    //   print('original image size:' + mb.toString());
    // }

    await _cropImage();
  }

  Future _cropImage() async {
    if (_selectImage != null) {
      CroppedFile? croppedFile = await ImageCropper()
          .cropImage(sourcePath: _selectImage!.path, aspectRatioPresets: [
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

        final result = await FlutterImageCompress.compressAndGetFile(
          croppedFile.path,
          targetPath,
          minHeight: 1080,
          minWidth: 1080,
          quality: 90,
        );

        final data = await result!.readAsBytes();
        final newKb = data.length / 1024;
        final newMb = newKb / 1024;

        if (kDebugMode) {
          print('compressed image size:' + newMb.toString());
        }

        setState(() {
          _image = File(result.path);
        });
      }
    }
  }

  TextEditingController postContent = TextEditingController();

  Future<void> _downloadImage() async {
    final response = await http.get(Uri.parse(widget.post.postMediaUrl!));

    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/profile_image.jpg';

      await File(filePath).writeAsBytes(response.bodyBytes);

      setState(() {
        _image = File(filePath);
        isLoading = false;
      });
    }
  }

  Future _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
        source: ImageSource
            .gallery); // Change source to ImageSource.camera for using the camera

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _editPost() async {
    String postId = widget.post.id!;
    String newPostContent = postContent.text;
    File? newPostMedia = _image;
    String newTag = tag;
    setState(() {
      isLoading = true;
    });
    // Check if there are no changes to post content or media

    // If the user does not select a new image, use the existing image URL
    if (_image == null &&
        (widget.post.postMediaUrl != null &&
            widget.post.postMediaUrl.isNotEmpty)) {
      newPostMedia = null;
    }

    try {
      if (_image == null &&
          (widget.post.postMediaUrl != null &&
              widget.post.postMediaUrl.isNotEmpty)) {
        newPostMedia = null;
      } else {
        var result = await ApiService()
            .editPost(postId, newPostContent, newPostMedia, newTag);

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Post edited successfully")),
          );
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Home_Screen()),
              (route) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to edit post")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    tag = widget.post.tag;
    print(widget.post.tag);
    postContent = TextEditingController(text: widget.post.postContent);
    if (widget.post.postMediaUrl != null &&
        widget.post.postMediaUrl.isNotEmpty) {
      isLoading = true;
      _downloadImage();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xffF8FBFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Home_Screen()));
            },
            child: Image.asset('assets/Group.png')),
        centerTitle: true,
        title: Text(
          'Edit Post',
          style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xff1A1B23))),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                _editPost();
              },
              child: Text(
                'Edit',
                style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Color(0xff1A1B23))),
              ),
            ),
          )
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 30, top: 20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: widget.post.profileImageUrl == ''
                              ? AssetImage(
                                  'assets/account.png',
                                )
                              : NetworkImage(widget.post.profileImageUrl)
                                  as ImageProvider,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          widget.post.userName,
                          style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Color(0xff1A1B23))),
                        ),
                        Spacer(),
                        (tag != 'blank')
                            ? Container(
                                decoration: BoxDecoration(
                                    color: Colors.blueGrey,
                                    borderRadius: BorderRadius.circular(20)),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 4),
                                child: Text(
                                  widget.post.tag.toUpperCase(),
                                  style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: Colors.white,
                                          height: 2.5)),
                                ),
                              )
                            : Container(),
                        SizedBox(
                          width: 20,
                        )
                      ],
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ToggleButtons(
                        selectedBorderColor: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                        fillColor: Color(0xff1A1B23),
                        isSelected: _isSelected,
                        onPressed: (int index) async {
                          tag = all_tag[index];
                          setState(() {
                            // Toggle the state of the button at the given index

                            _isSelected[index] = !_isSelected[index];
                            // Update the state of other buttons
                            for (int buttonIndex = 0;
                                buttonIndex < _isSelected.length;
                                buttonIndex++) {
                              if (buttonIndex != index) {
                                _isSelected[buttonIndex] = false;
                              }
                            }
                          });
                        },
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.1),
                            child: Text(
                              "Blank",
                              style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: _isSelected[0]
                                          ? Colors.white
                                          : Color(0xff1A1B23))),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.1),
                            child: Text(
                              "Buy",
                              style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: _isSelected[1]
                                          ? Colors.white
                                          : Color(0xff1A1B23))),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.1),
                            child: Text(
                              "Sell",
                              style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: _isSelected[2]
                                          ? Colors.white
                                          : Color(0xff1A1B23))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(left: 30, top: 15),
                      child: TextField(
                        controller: postContent,
                        maxLines: null,
                        maxLength: 500,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText: 'Write something ...',
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Color(0xff919191),
                          ),
                          focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.transparent)),
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.transparent)),
                        ),
                      )),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        height: 200, // Adjust the height based on your design
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _image != null
                            ? Image.file(
                                _image!,
                                fit: BoxFit.cover,
                              )
                            : Container(),
                      )),
                ],
              ),
              Positioned(
                  bottom: 20,
                  right: 100,
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: FloatingActionButton(
                      backgroundColor: const Color(0xff102E44),
                      //foregroundColor: Colors.black,
                      mini: true,
                      onPressed: () {
                        imagePickerFromCamera();
                      },
                      child: Image.asset(
                        'assets/Vector.png',
                        height: 25,
                        width: 25,
                      ),
                    ),
                  )),
              Positioned(
                  bottom: 20,
                  right: 30,
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: FloatingActionButton(
                      backgroundColor: const Color(0xff102E44),
                      //foregroundColor: Colors.black,
                      mini: true,
                      onPressed: imagePickerFromGallery,
                      child: Image.asset(
                        'assets/Vector (1).png',
                        height: 25,
                        width: 25,
                      ),
                    ),
                  )),
            ]),
    );
  }
}
