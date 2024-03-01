import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omd/edit_profile.dart';
import 'package:omd/home.dart';
import 'package:image/image.dart' as img;
import 'package:omd/services/api_service.dart';
import 'package:omd/settings.dart';
import 'package:omd/widgets/utils.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:shared_preferences/shared_preferences.dart';

class WPost extends StatefulWidget {
  const WPost({Key? key}) : super(key: key);

  @override
  State<WPost> createState() => _WPostState();
}

class _WPostState extends State<WPost> {
  String? userId;
  String? profileImageUrl;
  String? firstName;
  String? lastName;
  String? email;
  String? flag;

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? '';
    profileImageUrl = prefs.getString('profileImageUrl') ?? '';
    firstName = prefs.getString('firstName') ?? '';
    lastName = prefs.getString('lastName');
    email = prefs.getString('email');
    flag = prefs.getString('flag');

    setState(() {}); // Trigger a rebuild to update the UI with the fetched data
  }

  File? _image;
  XFile? _selectImage;
  final picker = ImagePicker();
  bool isAddingPost = false;

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

  Future _getImageFromGallery() async {
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

  Future _getImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
        source: ImageSource
            .camera); // Change source to ImageSource.camera for using the camera

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  final postContent = TextEditingController();
  void _addPost() async {
    String postContents = postContent.text;
    File? compressedImage;

    setState(() {
      isAddingPost = true;
    });

    try {
      // Check if the image is selected

      var result;

      // Check if the compressed image is available
      if (_image != null && postContents.isNotEmpty) {
        result = await ApiService()
            .addPost(userId!, postContent: postContents, postMedia: _image);
      } else if (postContents.isEmpty) {
        result = await ApiService().addPost(userId!, postMedia: _image);
      } else {
        result = await ApiService().addPost(userId!, postContent: postContents);
      }

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Post added successfully")),
        );
        postContent.clear();
        _image = null;
        print(result['newPost']);
      } else {
        // if (result['message'] == "User can't post more than 2 times in a day") {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //         content: Text("User can't post more than 2 times in a day")),
        //   );
        // } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add post: ${result['message']}")),
        );
        //}
        print('User ID....${userId}');
        print("Error....${result['message']}");
      }
    } catch (error) {
      // Log the error for further analysis
      print("Error adding post: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add post")),
      );
    } finally {
      setState(() {
        isAddingPost = false;
      });
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Home_Screen()),
          (route) => false);
    }
  }

  @override
  void initState() {
    _fetchUserData();
    print("..............$userId");
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Write Post',
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
                print("Flag..............$flag");

                _addPost();
              },
              child: Text(
                'Post',
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
      body: isAddingPost
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(children: [
              Column(children: [
                Padding(
                  padding: const EdgeInsets.only(left: 30, top: 20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: profileImageUrl!.isEmpty
                            ? AssetImage('assets/account.png')
                            : NetworkImage(profileImageUrl!) as ImageProvider,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        firstName!,
                        style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Color(0xff1A1B23))),
                      ),
                    ],
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(left: 30, top: 15),
                    child: TextField(
                      controller: postContent,
                      maxLines: 3,
                      maxLength: 100,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: 'Write something ...',
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Color(0xff919191),
                        ),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent)),
                      ),
                    )),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _image != null
                          ? Image.file(
                              _image!,
                              fit: BoxFit.cover,
                            )
                          : null,
                    ))
              ]),
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
