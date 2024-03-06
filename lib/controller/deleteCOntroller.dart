

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import 'package:omd/services/api_service.dart';
import 'package:omd/utils/const.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/UserDetailsModel.dart';


class DeleteController extends GetxController{


  Future<String> getUserIdFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';
    return userId;
  }


  Future<void> deleteUser(String userId) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;


    try {
      Response response= await Dio().delete('$BASE_URL/api/users/$userId/delete_user', options: Options(followRedirects: true),);
      print(response.statusCode);
      await _firestore.collection('chats').doc(userId).delete();
      ApiService().deletePost(userId);
      print('Chat deleted successfully');
      if (response.statusCode! == 200 ) {
        print('User deleted successfully');
      } else {
        print('Failed to delete user. Status code: ${response.statusCode}');
      }

    } catch (e) {
      print('Error deleting user: $e');
    }
  }


  final Dio _dio = Dio();

  Future<UserData> getUserByPhoneNumber(String phoneNumber) async {
    try {
      final response = await _dio.get(
        'https://online-media-tools-server-vercel.vercel.app/api/users/$phoneNumber/getuser',
      );

      if (response.statusCode == 200) {
        print(response);
        print(response.data);
       return  UserData.fromJson(response.data);

      } else {
        throw Exception('Failed to load user');
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }


}