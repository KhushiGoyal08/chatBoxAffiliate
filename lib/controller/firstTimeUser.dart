
//
// import 'package:email_auth/email_auth.dart';
// import 'package:get/get_state_manager/src/simple/get_controllers.dart';
//
// class VerifyUser extends GetxController{
//   EmailAuth emailAuth =   EmailAuth(sessionName: "Sample session");
//
//   void sendOTP(String email) async{
//
//       bool response =await emailAuth.sendOtp(recipientMail:email ,otpLength: 6);
//       print(response);
//   }
//
//   bool validateEmail(String email,String otp)  {
//     var response = emailAuth.validateOtp(
//         recipientMail: email,
//         userOtp: otp);
//
//     if (response) {
//
//        return true;
//     }
//     else{
//       return false;
//     }
//   }
//
// }