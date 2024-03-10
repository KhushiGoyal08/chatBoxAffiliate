import 'dart:io';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:omd/home.dart';
import 'package:http/http.dart' as http;
import 'package:omd/services/api_service.dart';
import 'package:omd/widgets/my_textfield.dart';
import 'package:omd/widgets/utils.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Edit_Pro extends StatefulWidget {
  static String verify = '';
  Edit_Pro({
    Key? key,
  }) : super(key: key);

  @override
  State<Edit_Pro> createState() => _Edit_ProState();
}

class _Edit_ProState extends State<Edit_Pro> {
  GlobalKey<_Edit_ProState> editProKey = GlobalKey<_Edit_ProState>();
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
  String? otp;
  String? emailOtp;
  String? profileImage;
  // VerifyUser verifyEmail=Get.put(VerifyUser());
  String? userId;
  File? _image;
  String? otpCode;
  XFile? _selectImage;
  bool isPhoneVerified=false;
  final picker = ImagePicker();
  bool isLoading = false;
  bool _imageSelected = false;
  EmailOTP myauth = EmailOTP();
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
          _imageSelected = true;
        });
      }
    }
  }

  Future<void> verifyPhoneNumber(String newPhoneNumber,BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        PhoneVerificationCompleted verificationCompleted =
            (PhoneAuthCredential credential) async {

          print('Phone number updated successfully');
        };

        PhoneVerificationFailed verificationFailed =
            (FirebaseAuthException authException) {
          print('Phone verification failed: ${authException.message}');
        };

        PhoneCodeSent codeSent =
            (String verificationId, int? resendToken) async {
          Edit_Pro.verify = verificationId;

          print('.......${otpCode}');
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: TextFormField(
                    onChanged: (val) {
                      otp = val;
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(6), // Limit to 6 digits
                    ],
                    decoration: InputDecoration(
                      label: Text("Enter OTP"),
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
                      contentPadding: EdgeInsets.all(15),
                      hintText: "Enter OTP",
                      hintStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          color: Colors.black,
                          letterSpacing: -0.33,
                          fontFamily: 'Montserrat'),
                    ),
                  ),
                  actions: [
                    ElevatedButton(
                        onPressed: () async {
                          try{
                            PhoneAuthCredential credential =
                            PhoneAuthProvider.credential(
                              verificationId: Edit_Pro
                                  .verify, // Verification ID received during phone number change
                              smsCode:
                              otp!, // Confirmation code sent to the new phone number
                            );
                            await user.updatePhoneNumber(credential);
                            print("USer Phone NO Update Successfully");
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            prefs.setString('mobileNumber', newPhoneNumber);
                            print(prefs.getString('mobileNumber'));
                          await   ApiService().verifyUser(newPhoneNumber);
                          setState(() {
                            isPhoneVerified=true;
                          });
                            // await ApiService().registerAndUpdateProfile(userId: userId!, profilePicture: File(profileImage!), firstName: firstName.text, lastName: lastName.text, email: email.text, mobileNumber: newPhoneNumber, linkedIn: linkedin.text, skype: skype.text, telegram: telegram.text, instagram: instagram.text, facebook: facebook.text, company: company.text, designation:designation.text, aboutMe: aboutMe.text, token: token!, flag: flag);
                          }
                          catch(e){
                            Utils().toastMessage(context, 'Phone Number Not Updated', Colors.redAccent);
                            Utils().toastMessage(context, '$e', Colors.redAccent);
                          }

                          Navigator.of(context).pop();
                        },
                        child: Text("Verify OTP"))
                  ],
                );
              });

          setState(() async {

            isLoading = false;
          });
        };

        await FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: newPhoneNumber,
            verificationCompleted: verificationCompleted,
            verificationFailed: verificationFailed,
            codeSent: codeSent,
            codeAutoRetrievalTimeout: (e) {
              Utils().toastMessage(context, "Error Occurred", Colors.red);
              setState(() {
                isLoading = false;
              });
            });
      } else {
        print('User not signed in');
      }
    } catch (e) {
      print('Error verifying phone number: $e');
    }
  }

  Future<void> _downloadImage() async {
    if (profileImage != null) {
      final response = await http.get(Uri.parse(profileImage ?? ''));

      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/profile_image.jpg';

        await File(filePath).writeAsBytes(response.bodyBytes);

        setState(() {
          _image = File(filePath);
        });
      } else {
        print('Failed to download image. Status code: ${response.statusCode}');
      }
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

  String? token;
  String? flag;

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
        prefs.setString(
            'sessionExpiration', userData['sessionExpiration'] ?? '');
        prefs.setString('token', userData['token']);
        prefs.setString('flag', userData['flag']);
        print('User data saved successfully');
        print("User data saved in SharedPreferences");
      } catch (e) {
        print("Error sving data ${e}");
      }
    } else {
      print("userData is null");
    }
  }

  Future<void> _getUserDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      userId = prefs.getString('userId');
      firstName.text = prefs.getString('firstName') ?? '';
      lastName.text = prefs.getString('lastName') ?? '';
      email.text = prefs.getString('email') ?? '';
      profileImage = prefs.getString('profileImageUrl');
      mobileNumber.text = prefs.getString('mobileNumber') ?? '';
      linkedin.text = prefs.getString('LinkedIn') ?? '';
      skype.text = prefs.getString('Skype') ?? '';
      telegram.text = prefs.getString('Telegram') ?? '';
      instagram.text = prefs.getString('Instagram') ?? '';
      facebook.text = prefs.getString('Facebook') ?? '';
      company.text = prefs.getString('Company') ?? '';
      designation.text = prefs.getString('Designation') ?? '';
      aboutMe.text = prefs.getString('AboutMe') ?? '';
      token = prefs.getString('token');
      flag = prefs.getString('flag');
    });
    setState(() {});
  }

  @override
  void initState() {
    _downloadImage();
    _getUserDataFromSharedPreferences();
    // print(',,,,,,,,${widget.linkedin}');
    // print(".........${widget.profileImage}");

    // TODO: implement initState
    super.initState();
  }

  String? _countryCode;
  String? _countryFlagIcon;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: editProKey,
        body:
            // Obx(() => LoadingOverlay(
            //   isLoading: signupController.isLoading.value,
            //   child:

            Container(
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
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          if (_imageSelected &&
                              _image != null) // Show the selected image
                            ClipOval(
                              child: Container(
                                width: 160,
                                height: 160,
                                child: Image.file(
                                  _image!,
                                  width: 160,
                                  height: 160,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          if (_image == null &&
                              profileImage != null &&
                              profileImage!.isNotEmpty)
                            ClipOval(
                              child: Container(
                                width: 160,
                                height: 160,
                                child: Image.network(
                                  profileImage!,
                                  width: 160,
                                  height: 160,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          if (_image == null &&
                              (profileImage == null || profileImage!.isEmpty))
                            ClipOval(
                              child: Container(
                                width: 160,
                                height: 160,
                                child: Image.asset(
                                  'assets/account.png', // Replace with your asset image path
                                  width: 160,
                                  height: 160,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          IconButton(
                            padding: const EdgeInsets.only(left: 90, top: 130),
                            icon: const Icon(Icons.camera_alt),
                            onPressed: () {
                              imagePickerFromGallery();
                              setState(() {
                                _imageSelected = false;
                              });
                            },
                            color: const Color(0xff102E44),
                            iconSize: 36.0,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Form(
                        child: Column(children: [
                      MyTextField(
                        controller: firstName,
                        hintText: "First Name",
                        hintLabel: Text("First Name"),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      MyTextField(
                          hintLabel: Text("Label Name"),
                          controller: lastName,
                          hintText: "Last Name"),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: 320,
                        child: TextFormField(
                          controller: email,
                          decoration:const  InputDecoration(
                            label: Text(' Email'),
                            focusedBorder:  OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(46),
                                topRight: Radius.circular(46),
                                bottomLeft: Radius.circular(46),
                                bottomRight: Radius.circular(46),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              // borderSide: BorderSide(color: Colors.blue, width: 0.4),
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(46),
                                topRight: Radius.circular(46),
                                bottomLeft: Radius.circular(46),
                                bottomRight: Radius.circular(46),
                              ),
                            ),
                            contentPadding: EdgeInsets.all(15),
                            hintText: 'Enter the Email',
                            hintStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                color: Colors.black,
                                letterSpacing: -0.33,
                                fontFamily: 'Montserrat'),
                          ),
                          validator: (v) {
                            if (v!.isEmpty) {
                              return "Enter the Email";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: IntlPhoneField(
                          initialCountryCode: 'IN',
                          style: TextStyle(fontSize: 17),
                          dropdownIcon: Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xff102E44),
                          ),
                          dropdownTextStyle: TextStyle(fontSize: 15),
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black12),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(46),
                                  topRight: Radius.circular(46),
                                  bottomLeft: Radius.circular(46),
                                  bottomRight: Radius.circular(46),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                // borderSide: BorderSide(color: Colors.blue, width: 0.4),
                                borderSide: BorderSide(color: Colors.black12),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(46),
                                  topRight: Radius.circular(46),
                                  bottomLeft: Radius.circular(46),
                                  bottomRight: Radius.circular(46),
                                ),
                              ),
                              labelText: 'Phone Number',
                              labelStyle: TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xff102E44)),
                              )),
                          // controller: mobileNumber,
                          onChanged: (phone) {
                            String countryCode = phone.countryISOCode;
                            _countryFlagIcon = countryCode
                                .toUpperCase()
                                .replaceAllMapped(
                                    RegExp(r'[A-Z]'),
                                    (match) => String.fromCharCode(
                                        match.group(0)!.codeUnitAt(0) +
                                            127397));
                            print(_countryFlagIcon);
                            _countryCode = phone.completeNumber;
                            print(_countryCode);
                            setState(() {});
                          },
                          onSubmitted: (phone) async {
                            User user = FirebaseAuth.instance.currentUser!;
                            phone = _countryCode!;
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            var ph = prefs.getString('mobileNumber');
                            print(ph);
                            print(phone);
                            if (ph != phone) {
                              try {
                                verifyPhoneNumber(phone,context);
                              } catch (error) {
                                Utils().toastMessage(context,
                                    'Failed to call API. $error', Colors.red);
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            }
                            else{
                              Utils().toastMessage(context, 'Same Number', Colors.black);
                            }
                          },
                        ),
                      ),
                      // MyTextField(
                      //     // readOnly: true,
                      //     hintLabel: Text("Mobile Number"),
                      //     controller: mobileNumber,
                      //     hintText: "Mobile Number"),
                      const SizedBox(
                        height: 20,
                      ),
                      MyTextField(
                          hintLabel: Text("Linkedin"),
                          controller: linkedin,
                          hintText: "Linkedin"),
                      const SizedBox(
                        height: 20,
                      ),
                      MyTextField(
                          hintLabel: Text("Skype"),
                          controller: skype,
                          hintText: "Skype"),
                      const SizedBox(
                        height: 20,
                      ),
                      MyTextField(
                          hintLabel: Text("Telegram"),
                          controller: telegram,
                          hintText: "Telegram"),
                      const SizedBox(
                        height: 20,
                      ),
                      MyTextField(
                          hintLabel: Text("Instagram"),
                          controller: instagram,
                          hintText: "Instagram"),
                      const SizedBox(
                        height: 20,
                      ),
                      MyTextField(
                          hintLabel: Text("Facebook"),
                          controller: facebook,
                          hintText: "Facebook"),
                      const SizedBox(
                        height: 20,
                      ),
                      MyTextField(
                          hintLabel: Text("Company"),
                          controller: company,
                          hintText: "Company"),
                      const SizedBox(
                        height: 20,
                      ),
                      MyTextField(
                          hintLabel: Text("Designation"),
                          controller: designation,
                          hintText: "Designation"),
                      const SizedBox(
                        height: 20,
                      ),
                      MyTextField(
                        hintLabel: Text("About Me"),
                        controller: aboutMe,
                        hintText: "About Me",
                      ),
                    ])),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (mobileNumber.text.isNotEmpty) {
                          setState(() {
                            isLoading = true;
                          });

                          if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                              .hasMatch(email.text)) {
                            Utils().toastMessage(context,
                                'Please enter valid email id', Colors.red);
                            setState(() {
                              isLoading = false; // Set loading to false
                            });
                          } else {
                            final result = await ApiService()
                                .registerAndUpdateProfile(
                                    userId: userId!,
                                    profilePicture: _image,
                                    firstName: firstName.text.trim(),
                                    lastName: lastName.text.trim(),
                                    email: email.text.trim(),
                                    mobileNumber:(isPhoneVerified)? _countryCode!:mobileNumber.text,
                                    linkedIn: linkedin.text.trim(),
                                    skype: skype.text.trim(),
                                    telegram: telegram.text.trim(),
                                    instagram: instagram.text.trim(),
                                    facebook: facebook.text.trim(),
                                    company: company.text.trim(),
                                    designation: designation.text.trim(),
                                    aboutMe: aboutMe.text.trim(),
                                    token: token!,
                                    flag: flag!);
                            await clearUserData();
                            if (result['success']) {
                              print("UserData before saving: $result[data]");
                              _saveUserDataInSharedPreferences(
                                  result['data']['existingUser']);
                              setState(() {
                                isLoading = false;
                              });
                              // Handle successful signup
                              print("Sign Up successful");
                              print(result['data']);
                              // Now you can use result['data'] as the user data in your app
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Home_Screen()),
                                  (route) => false);
                            } else {
                              isLoading = false;
                              // Handle signup failure
                              print("Edit Profile failed");
                              print(result['message']);
                              Utils().toastMessage(
                                  context, result['message'], Colors.red);
                              // Display an error message or handle the failure as needed
                            }
                          }
                        } else {
                          Utils().toastMessage(context,
                              'Please enter the mobile number', Colors.red);
                        }
                      },
                      child: isLoading
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : Container(
                              width: 320,
                              height: 50,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(55),
                                  topRight: Radius.circular(55),
                                  bottomLeft: Radius.circular(55),
                                  bottomRight: Radius.circular(55),
                                ),
                                color: Color(0xff102E44),
                              ),
                              child: const Center(
                                child: Text(
                                  'SAVE',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color.fromRGBO(255, 255, 255, 1),
                                      fontFamily: 'Roboto',
                                      fontSize: 18,
                                      letterSpacing: -0.40799999237060547,
                                      fontWeight: FontWeight.normal,
                                      height: 1.2222222222222223),
                                ),
                              )),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                  ],
                ) // Foreground widget here
                )
        // : Center(
        //     child: CircularProgressIndicator(),
        // ),)
        );
  }
}
