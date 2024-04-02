import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../model/partnerModel.dart';

class PartnerController extends GetxController {
  var partnersList = <Allpartner>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  void fetchData() async {
    try {
      final response = await Dio().get(
          'https://online-media-tools-server-vercel.vercel.app/api/users/allpartners');
      if (response.statusCode == 200) {
        PartnerModel partnerModel = PartnerModel.fromJson(response.data);
        partnersList.assignAll(partnerModel.allpartners);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
