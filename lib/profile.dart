import 'dart:io';


import 'package:flutter/material.dart';
import 'package:get/get.dart';


import 'package:google_fonts/google_fonts.dart';
import 'package:omd/pages/guestUserScreen.dart';

import 'package:omd/settings.dart';
import 'package:omd/sign_ups.dart';

import 'package:omd/widgets/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'controller/deleteCOntroller.dart';
import 'edit_profile.dart';

import 'home.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? userId;
  String? profileImage;
  String? firstName;
  String? lastName;
  String? designation;
  String? companyName;
  String? facebook;
  String? instagram;
  String? linkedin;
  String? aboutMe;
  String? mobileNumber;
  String? email;
  String? skype;
  String? telegram;
  final DeleteController deleteController=Get.put(DeleteController());

  Future<void> _fetchUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId') ?? '';
      profileImage = prefs.getString('profileImageUrl') ?? '';
      firstName = prefs.getString('firstName');
      designation = prefs.getString('Designation');
      lastName = prefs.getString('lastName');
      companyName = prefs.getString('Company');
      facebook = prefs.getString('Facebook');
      instagram = prefs.getString('Instagram');
      linkedin = prefs.getString('LinkedIn');
      aboutMe = prefs.getString('AboutMe');
      email = prefs.getString('email');
      mobileNumber = prefs.getString('mobileNumber');
      skype = prefs.getString('Skype');
      telegram = prefs.getString('Telegram');

      // No need to call setState here as it's not necessary for FutureBuilder
    } catch (error) {
      print('Error: $error');
      // Propagate the error to the FutureBuilder
      throw error;
    } // Trigger a rebuild to update the UI with the fetched data
  }

  @override
  void initState() {
    // _fetchUserData();
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
          actions: [
            IconButton(
                onPressed: () {
                  Get.to(() => Edit_Pro());
                },
                icon: Icon(
                  Icons.edit,
                  color: Colors.white,
                )),
            IconButton(
                onPressed: () async{
                  showDialog(context: context, builder: (BuildContext context){
                    return Dialog(
                      child: Container(
                        height: MediaQuery.of(context)
                            .size
                            .height *
                            0.35,
                        child: Padding(
                          padding: const EdgeInsets
                              .all(
                              20),
                          child: Column(

                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text("Do you really want to delete your profile ?? This action will remove your all chats and profile.",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black, fontFamily: 'Montserrat', fontSize: 17,),
                              ),
                              Row(

                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(onPressed: (){
                                    Navigator.pop(context);
                                  },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xff102E44),
                                      ),
                                      child: Text(
                                    "No",
                                    style: TextStyle(
                                      color: Color.fromRGBO(255, 255, 255, 1),
                                      fontFamily: 'Montserrat',
                                      fontSize: 17,
                                    ),
                                  )),
                                  ElevatedButton(onPressed: ()async {
                                      String userId = await deleteController.getUserIdFromSharedPreferences();
                                      deleteController.deleteUser(userId);
                                      // Get.to(() => PermissionGuestUser());
                                      Get.offAll(() => Sign_Up());
                                  },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xff102E44),
                                      ),
                                      child: Text(
                                        "Yes",
                                        style: TextStyle(
                                          color: Color.fromRGBO(255, 255, 255, 1),
                                          fontFamily: 'Montserrat',
                                          fontSize: 17,
                                        ),
                                      ))
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  });
                //   String userId = await getUserIdFromSharedPreferences();
                //   deleteController.deleteUser(userId);
                //   Get.to(() => PermissionGuestUser());
                },
                icon: Icon(
                  Icons.delete,
                  color: Colors.white,
                )),
          ],
          centerTitle: true,
          title: Text('Profile',
              style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.white))),
        ),
        body: FutureBuilder<void>(
            future: _fetchUserData(), // Use _fetchUserData as the future
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Show a loading indicator while waiting for the data
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                // Show an error message if there's an error
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: Column(
                            children: [
                              if (profileImage!.isNotEmpty)
                                Center(
                                  child: FutureBuilder<bool>(
                                    // Simulate a delay of 2 seconds
                                    future: Future.delayed(
                                        Duration(seconds: 2), () => true),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        // Show the loading indicator for 2 seconds
                                        return CircularProgressIndicator();
                                      } else {
                                        // Image is fully loaded, show the content
                                        return Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Image.network(
                                              profileImage!,
                                              height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                                  8,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                                  4,
                                              loadingBuilder: (BuildContext context,
                                                  Widget child,
                                                  ImageChunkEvent?
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  // Image is fully loaded
                                                  return child;
                                                } else {
                                                  // Image is still loading, show a loading indicator
                                                  return Center(
                                                    child:
                                                    CircularProgressIndicator(),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                )
                              else ...{
                                Center(
                                  child: Container(
                                    child: Image.asset(
                                      'assets/account.png',
                                      height:
                                      MediaQuery.of(context).size.height / 8,
                                      width: MediaQuery.of(context).size.width / 4,
                                    ),
                                  ),
                                ),
                              },
                              SizedBox(
                                height: 10,
                              ),
                              if (firstName!.isNotEmpty && lastName!.isNotEmpty)
                                Text(
                                  '$firstName $lastName',
                                  style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          color: Colors.black)),
                                ),
                              if (email!.isNotEmpty)
                                Text(
                                  email!,
                                  style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color: Colors.black38)),
                                ),
                              if (designation!.isNotEmpty)
                                Text(
                                  designation!,
                                  style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color: Colors.black38)),
                                ),
                              if (companyName!.isNotEmpty)
                                Text(
                                  companyName!,
                                  style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color: Colors.black38)),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (facebook!.isNotEmpty)
                              RowImageWithText(
                                image: 'assets/facebook.png',
                                text: facebook!,
                              ),
                            const SizedBox(height: 5),
                            if (linkedin!.isNotEmpty)
                              RowImageWithText(
                                  image: 'assets/linkd.png', text: linkedin!),
                            if (linkedin!.isNotEmpty) SizedBox(height: 10),
                            if (instagram!.isNotEmpty)
                              RowImageWithText(
                                  image: 'assets/insta.png', text: instagram!),
                            if (instagram!.isNotEmpty)
                              SizedBox(
                                height: 10,
                              ),
                            if (telegram!.isNotEmpty)
                              RowImageWithText(
                                  image: 'assets/telegram.png', text: telegram!),
                            if (telegram!.isNotEmpty) const SizedBox(height: 10),
                            if (skype!.isNotEmpty)
                              RowImageWithText(
                                  image: 'assets/skype.png', text: skype!),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(
                                thickness: 1,
                              ),
                              Text(
                                'About Me',
                                style: GoogleFonts.poppins(
                                    textStyle: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.black)),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              if (aboutMe!.isNotEmpty)
                                Text(
                                  aboutMe!,
                                  maxLines: 20,
                                  style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color: Colors.black38)),
                                ),
                              SizedBox(
                                height: 20,
                              ),
                              if (mobileNumber!.isNotEmpty)
                                Text(
                                  mobileNumber!,
                                  style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color: Colors.black38)),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ));
              }
            }));
  }
}

class RowImageWithText extends StatelessWidget {
  final String image;
  final String text;
  RowImageWithText({
    super.key,
    required this.image,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Image.asset(
            image,
            height: 30,
            width: 30,
          ),
          SizedBox(
              width: 250,
              child: Text(
                text,
                maxLines: 3,
              )),
        ],
      ),
    );

  }

}
