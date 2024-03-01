

import 'package:dio/dio.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';


class DeleteController extends GetxController{
  final String baseUrl = 'https://online-media-tools-server-vercel.vercel.app/api/users';

  Future<void> deleteUser(String userId) async {

    try {
      Response response= await Dio().delete('$baseUrl/$userId/delete_user', options: Options(followRedirects: true),);
      print(response.statusCode);
      if (response.statusCode! == 200 ) {
        print('User deleted successfully');
      } else {
        print('Failed to delete user. Status code: ${response.statusCode}');
      }

    } catch (e) {
      print('Error deleting user: $e');
    }
  }

}