import 'package:flutter/material.dart';
import 'package:flutter_chat_app/widgets/chat_user_card.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../api/api_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SalesApp Chat'),
        leading: const Icon(Icons.home),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await ApiServices.auth.signOut();
          await GoogleSignIn().signOut();
        }, child: const Icon(Icons.add_comment),
      ),
      body: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: 6,
        itemBuilder: (context, index) {
          return const ChatUserCard();
        }
      ),
    );
  }
}
