import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/api/api_services.dart';
import 'package:flutter_chat_app/auth/login_screen.dart';
import 'package:flutter_chat_app/screens/home_screen.dart';

import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 10), () {
      if(ApiServices.auth.currentUser != null){
        log('\nuser: ${ApiServices.auth.currentUser}');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: mq.height * .20,
            right: mq.width * .25,
            width: mq.width * .4,
            child: Image.asset('images/meetme.png'),
          ),
          Positioned(
            bottom: mq.height * .15,
            width: mq.width,
            child: const Text('Developed By Dharmendra ❤️', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.black87),),
          ),
        ],
      ),
    );
  }
}
