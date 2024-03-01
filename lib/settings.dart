import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omd/home.dart';
import 'package:omd/profile.dart';
import 'package:http/http.dart' as http;
import 'package:omd/services/api_service.dart';
import 'package:omd/widgets/my_textfield.dart';
import 'package:omd/widgets/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'edit_profile.dart';

class SettingsPage extends StatefulWidget {
  final String? userId;
  final String? firstName;
  final String? lastName;
  final String? mobileNumer;
  final String? email;
  final String? linkedin;
  final String? skype;
  final String? telegram;
  final String? instagram;
  final String? facebook;
  final String? company;
  final String? designation;
  final String? aboutMe;
  final String? profileImage;
  const SettingsPage(
      {Key? key,
      this.userId,
      this.firstName,
      this.lastName,
      this.mobileNumer,
      this.email,
      this.linkedin,
      this.skype,
      this.telegram,
      this.instagram,
      this.facebook,
      this.company,
      this.designation,
      this.aboutMe,
      this.profileImage})
      : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? profileImage;
  String? userId;
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController mobileNumber = TextEditingController();

  TextEditingController linkedin = TextEditingController();
  TextEditingController skype = TextEditingController();
  TextEditingController telegram = TextEditingController();
  TextEditingController instagram = TextEditingController();
  TextEditingController facebook = TextEditingController();
  TextEditingController company = TextEditingController();
  TextEditingController designation = TextEditingController();
  TextEditingController aboutMe = TextEditingController();
  final _key = GlobalKey<FormState>();

  File? _image;
  bool isLoading = false;
  Future<void> _downloadImage() async {
    final response = await http.get(Uri.parse(widget.profileImage!));

    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/profile_image.jpg';

      await File(filePath).writeAsBytes(response.bodyBytes);

      setState(() {
        _image = File(filePath);
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

  Future<void> clearUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userId', '');
    prefs.setString('firstName', '');
    prefs.setString('lastName', '');
    prefs.setString('email', '');
    prefs.setString('mobileNumber', '');
    prefs.setString('profileImageUrl', '');
    prefs.setString('AboutMe', '');
    prefs.setString('Company', '');
    prefs.setString('Designation', '');
    prefs.setString('Facebook', '');
    prefs.setString('Instagram', '');
    prefs.setString('Linkedin', '');
    prefs.setString('Skype', '');
    prefs.setString('Telegram', '');
    prefs.setString('jwttoken', '');
    prefs.setString('sessionExpiration', '');
    print('Clearing user data from SharedPreferences');
    prefs.clear(); // Make sure this clears the data
  }

  Future<void> _saveUserDataInSharedPreferences(
      Map<String, dynamic>? userData) async {
    if (userData != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      try {
        prefs.setString('userId', userData['_id'] ?? '');
        prefs.setString('firstName', userData['firstName'] ?? '');
        prefs.setString('lastName', userData['lastName'] ?? '');
        prefs.setString('email', userData['email'] ?? '');
        prefs.setString('mobileNumber', userData['mobileNumber'] ?? '');
        prefs.setString('profileImageUrl', userData['profileImageUrl'] ?? '');
        prefs.setString('AboutMe', userData['AboutMe'] ?? '');
        prefs.setString('Company', userData['Company'] ?? '');
        prefs.setString('Designation', userData['Designation'] ?? '');
        prefs.setString('Facebook', userData['Facebook'] ?? '');
        prefs.setString('Instagram', userData['Instagram'] ?? '');
        prefs.setString('LinkedIn', userData['LinkedIn'] ?? '');
        prefs.setString('Skype', userData['Skype'] ?? '');
        prefs.setString('Telegram', userData['Telegram'] ?? '');
        prefs.setString('jwttoken', userData['jwttoken'] ?? '');
        prefs.setString('token', userData['token']);
        prefs.setString('flag', userData['flag']);
        prefs.setString(
            'sessionExpiration', userData['sessionExpiration'] ?? '');
        print('User data saved successfully');
        print("User data saved in SharedPreferences");
      } catch (e) {
        print("Error sving data ${e}");
      }
    } else {
      print("userData is null");
    }
  }

  String? token;
  String? flag;

  Future<void> _getUserDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      userId = prefs.getString('userId');
      firstName.text = prefs.getString('firstName') ?? '';
      lastName.text = prefs.getString('lastName') ?? '';
      profileImage = prefs.getString('profileImageUrl') ?? '';
      email.text = prefs.getString('email') ?? '';
      mobileNumber.text = prefs.getString('mobileNumber') ?? '';
      linkedin.text = prefs.getString('LinkedIn') ?? '';
      skype.text = prefs.getString('Skype') ?? '';
      telegram.text = prefs.getString('Telegram') ?? '';
      instagram.text = prefs.getString('Instagram') ?? '';
      facebook.text = prefs.getString('Facebook') ?? '';
      company.text = prefs.getString('Company') ?? '';
      designation.text = prefs.getString('Designation') ?? '';
      aboutMe.text = prefs.getString('AboutMe') ?? '';
      token = prefs.getString('token') ?? '';
      flag = prefs.getString('flag') ?? '';
    });
    setState(() {});
  }

  @override
  void initState() {
    _downloadImage();
    _getUserDataFromSharedPreferences();
    print(',,,,,,,,${widget.linkedin}');
    firstName = TextEditingController(text: widget.firstName);
    lastName = TextEditingController(text: widget.lastName);
    email = TextEditingController(text: widget.email);
    mobileNumber = TextEditingController(text: widget.mobileNumer);

    linkedin = TextEditingController(text: widget.linkedin);
    skype = TextEditingController(text: widget.skype);
    telegram = TextEditingController(text: widget.telegram);
    instagram = TextEditingController(text: widget.instagram);
    facebook = TextEditingController(text: widget.facebook);
    company = TextEditingController(text: widget.company);
    designation = TextEditingController(text: widget.designation);
    aboutMe = TextEditingController(text: widget.aboutMe);

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff102E44),
        leading: GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Home_Screen()));
          },
          child: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        title: Text('Settings',
            style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.white))),
        actions: [
          GestureDetector(
            onTap: () {
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => Edit_Pro(
              //               userId: userId,
              //               firstName: firstName.text,
              //               lastName: lastName.text,
              //               mobileNumer: mobileNumber.text,
              //               email: email.text,
              //               linkedin: linkedin.text,
              //               skype: skype.text,
              //               telegram: telegram.text,
              //               instagram: instagram.text,
              //               facebook: facebook.text,
              //               company: company.text,
              //               designation: designation.text,
              //               aboutMe: aboutMe.text,
              //               profileImage:
              //                   profileImage, // Assuming _image is the profile image in the Profile screen
              //             )));
            },
            child: const Padding(
              padding: EdgeInsets.all(15.0),
              child: Icon(Icons.edit, color: Colors.white),
            ),
          ),
        ],
      ),
      body:
          // Obx(() => LoadingOverlay(
          //   isLoading: signupController.isLoading.value,
          //   child:
          userId != null
              ? Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  height: double.infinity,
                  // width: double.infinity,
                  child: ListView(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.black12,
                        radius: 80,
                        child: ClipOval(
                          child:
                              profileImage != null && profileImage!.isNotEmpty
                                  ? Image.network(
                                      profileImage!,
                                      width:
                                          160, // Adjust the width and height as needed
                                      height: 160,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/account.png',
                                      width:
                                          120, // Adjust the width and height as needed
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Form(
                          key: _key,
                          child: Column(children: [
                            MyTextField(
                              controller: firstName,
                              hintText: "First Name",
                              readOnly: true,
                              hintLabel: Text("First Name"),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            MyTextField(
                                hintLabel: Text("Label Name"),
                                readOnly: true,
                                controller: lastName,
                                hintText: "Last Name"),
                            const SizedBox(
                              height: 20,
                            ),
                            MyTextField(
                                hintLabel: Text("Email"),
                                readOnly: true,
                                controller: email,
                                hintText: "Email"),
                            const SizedBox(
                              height: 20,
                            ),
                            MyTextField(
                                readOnly: true,
                                hintLabel: Text("Mobile Number"),
                                controller: mobileNumber,
                                hintText: "Mobile Number"),
                            const SizedBox(
                              height: 20,
                            ),
                            MyTextField(
                                hintLabel: Text("Linkedin"),
                                readOnly: true,
                                controller: linkedin,
                                hintText: "Linkedin"),
                            const SizedBox(
                              height: 20,
                            ),
                            MyTextField(
                                hintLabel: Text("Skype"),
                                controller: skype,
                                readOnly: true,
                                hintText: "Skype"),
                            const SizedBox(
                              height: 20,
                            ),
                            MyTextField(
                                hintLabel: Text("Telegram"),
                                controller: telegram,
                                readOnly: true,
                                hintText: "Telegram"),
                            const SizedBox(
                              height: 20,
                            ),
                            MyTextField(
                                hintLabel: Text("Instagram"),
                                controller: instagram,
                                readOnly: true,
                                hintText: "Instagram"),
                            const SizedBox(
                              height: 20,
                            ),
                            MyTextField(
                                hintLabel: Text("Facebook"),
                                controller: facebook,
                                readOnly: true,
                                hintText: "Facebook"),
                            const SizedBox(
                              height: 20,
                            ),
                            MyTextField(
                                hintLabel: Text("Company"),
                                readOnly: true,
                                controller: company,
                                hintText: "Company"),
                            const SizedBox(
                              height: 20,
                            ),
                            MyTextField(
                                hintLabel: Text("Designation"),
                                readOnly: true,
                                controller: designation,
                                hintText: "Designation"),
                            const SizedBox(
                              height: 20,
                            ),
                            MyTextField(
                              readOnly: true,
                              hintLabel: Text("About Me"),
                              controller: aboutMe,
                              hintText: "About Me",
                              maxLines: 10,
                            ),
                          ])),
                      const SizedBox(
                        height: 20,
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                    ],
                  ) // Foreground widget here
                  )
              : Center(
                  child: CircularProgressIndicator(),
                ),
      // ),)
    );
  }
}
