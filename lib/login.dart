import 'package:flutter/material.dart';
import 'package:omd/home.dart';
import 'package:omd/signup.dart';

class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // Obx(() => LoadingOverlay(
        //   isLoading: signupController.isLoading.value,
        //   child:
        body: Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            height: double.infinity,
            // width: double.infinity,
            child: ListView(
              children: [
                const SizedBox(
                  height: 70,
                ),

                Image.asset(
                  'assets/logo-black.png',
                  height: 300,
                  width: 300,
                ),
                const SizedBox(
                  height: 80,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Home_Screen()));
                  },
                  child: Container(
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
                          'LOG IN',
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
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) => SignUp()));
                  },
                  child: Container(
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
                          'SIGN UP',
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
                  height: 20,
                ),
                // const Padding(
                //   padding: EdgeInsets.only(left: 15),
                //   child: Text('Forgot Password?', textAlign: TextAlign.left, style: TextStyle(
                //       color : Color(0xff102E44),
                //       fontFamily: 'Roboto',
                //       fontSize: 16,
                //       letterSpacing: -0.40799999237060547,
                //       fontWeight: FontWeight.normal,
                //       height: 1.375
                //   ),),
                // ),
                // const SizedBox(height: 10,),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     const Text(
                //       'Don’t have an Account?',
                //       style: TextStyle(
                //         fontSize: 14,
                //         fontWeight: FontWeight.w400,
                //         color: Color(0xffA4A4A4),
                //         fontFamily: 'Roboto',
                //       ),
                //     ),
                //     GestureDetector(
                //       onTap: () {
                //         Navigator.push(context, MaterialPageRoute(builder: (context)=>SignUp()));
                //       },
                //       child: const Text(
                //         ' Signup',
                //         style: TextStyle(
                //           fontSize: 14,
                //           fontWeight: FontWeight.w400,
                //           color : Color(0xff102E44),
                //           fontFamily: 'Roboto',
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ) // Foreground widget here
            ),
      ),
    );
  }
}
