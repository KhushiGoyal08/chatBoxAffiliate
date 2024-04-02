import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controller/memberdirectory_page.dart';

class MemberDirectory extends StatelessWidget {
  MemberDirectory({super.key});
  final memberController = Get.put(MemberDirectoryController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff102E44),
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
          ),
          title: Text(
            "Member Directory",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Obx(() => memberController.memberDirectory.value.allusers.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                          " Total Users: ${memberController.memberDirectory.value.length.toString()}",
                          style: GoogleFonts.poppins(
                              fontSize: 24, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16, top: 72, right: 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: memberController
                          .memberDirectory.value.allusers.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemBuilder: (context, index) {
                        final user = memberController
                            .memberDirectory.value.allusers[index];
                        return Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors
                                      .black45, // specify the border color here
                                  width: 1, // specify the border width here
                                ),
                                borderRadius: BorderRadius.circular(15)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                (user.profileImageUrl != null)
                                    ? CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(user.profileImageUrl!),
                                        radius: 35,
                                      )
                                    : CircleAvatar(
                                        backgroundImage:
                                            AssetImage('assets/account.png'),
                                        radius: 35,
                                      ),
                                Column(
                                  children: [
                                    Text(user.firstName,
                                        style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500)),
                                    Text(user.lastName,
                                        style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ],
                            ));
                      },
                    ),
                  )
                ],
              )));
  }
}
