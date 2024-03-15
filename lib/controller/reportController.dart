import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:omd/utils/const.dart';



class ReportController extends GetxController {


  // Function to report a user
  Future<void> reportUser(String reportedId, String reporterId, String reason) async {
    try {
      // Make the API call
      print(reporterId+" " + reportedId+ " " +reason);
      final response = await http.post(
        Uri.parse('$BASE_URL/api/users/reportuser'),
        body: json.encode({
          'reportedId': reportedId,
          'reporterId': reporterId,
          'reason': reason,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      print(response.body);
      print(response.statusCode);
      // Show a snackbar or perform other actions to notify the user of success
      Get.snackbar('Success', 'User reported successfully');
    } catch (error) {
      // Handle errors, you might want to show a snackbar or perform other actions
      print('Error reporting user: $error');
      Get.snackbar('Error', 'Failed to report user. Please try again.');
    }
  }
}