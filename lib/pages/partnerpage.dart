import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/partnerController.dart';

class PartnerPage extends StatelessWidget {
  final PartnerController controller = Get.put(PartnerController());

  void _launchURL(String ur) async {
    final url = Uri.parse(ur);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch $url',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

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
          "All Partners",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.partnersList.isEmpty) {
          return Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
            itemCount: controller.partnersList.length,
            itemBuilder: (context, index) {
              final partner = controller.partnersList[index];
              return Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black45, // specify the border color here
                      width: 1, // specify the border width here
                    ),
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                Colors.black45, // specify the border color here
                            width: 1, // specify the border width here
                          ),
                          borderRadius: BorderRadius.circular(26)),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(partner.logo),
                        radius: 25,
                      ),
                    ),
                    Text(partner.description,
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff102E44),
                      ),
                      onPressed: () {
                        _launchURL(partner.link);
                      },
                      child: Text("Get in Touch",
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500)),
                    )
                  ],
                ),
                // You can add more details here if needed
              );
            },
          );
        }
      }),
    );
  }
}
