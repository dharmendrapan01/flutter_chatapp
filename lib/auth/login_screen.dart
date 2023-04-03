import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/helper/show_message.dart';
import 'package:flutter_chat_app/screens/home_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../api/api_services.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGoogleButtonClick() {
    DialogsMessage.showProgressbar(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      // log('\nuser: ${user?.user}');
      // log('\nuser Additional Information: ${user?.additionalUserInfo}');

      if(await ApiServices.userExists()) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }else{
        await ApiServices.createUser().then((value) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        });
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try{
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await ApiServices.auth.signInWithCredential(credential);
    }catch(e){
      log('\nError when signin with google: $e');
      DialogsMessage.showSnackbar(context, 'Something went wrong (check internet!)');
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome To SalesApp Chat'),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            top: mq.height * .15,
            right: _isAnimate ? mq.width * .30 : -mq.width * .5,
            width: mq.width * .4,
              child: Image.asset('images/meetme.png'),
          ),
          Positioned(
            bottom: mq.height * .15,
            left: mq.width * .09,
            width: mq.width * .8,
            height: mq.width * .1,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 223, 255, 187),
                shape: const StadiumBorder(),
                elevation: 1,
              ),
                onPressed: () {
                _handleGoogleButtonClick();
                },
                icon: Image.asset('images/google.png', height: mq.height * .03,),
                label: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    children: [
                      TextSpan(text: 'Sign In With ',),
                      TextSpan(text: 'Google', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ),
          ),
        ],
      ),
    );
  }
}
