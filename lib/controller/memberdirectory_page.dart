import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:omd/model/MemberDirectory.dart';
import 'package:omd/utils/const.dart';

class MemberDirectoryController extends GetxController {
  final Dio _dio = Dio();
  var memberDirectory =
      MemberDirectoryModel(message: "", length: 0, allusers: []).obs;
  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await _dio.get('$BASE_URL/api/users/memberdirectory');

      if (response.statusCode == 200) {
        memberDirectory.value = MemberDirectoryModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
