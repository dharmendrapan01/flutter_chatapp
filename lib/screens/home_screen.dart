import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_app/screens/profile_screen.dart';
import 'package:flutter_chat_app/widgets/chat_user_card.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../api/api_services.dart';
import '../modals/user_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    ApiServices.getSelfInfo();

    // for setting user status to active
    ApiServices.updateActiveStatus(true);

    // for updating user active status according to lifecycle events
    // resume -- active or online
    // pause -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      // log('message $message');
      if(ApiServices.auth.currentUser != null){
        if(message.toString().contains('resume')) ApiServices.updateActiveStatus(true);
        if(message.toString().contains('pause')) ApiServices.updateActiveStatus(false);
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        // if search is on and back button is pressed then close search
        // or else simple close current screen on back button click
        onWillPop: () {
          if(_isSearching){
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          }else{
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: _isSearching ? TextField(
              onChanged: (val) {
                // search logic here
                _searchList.clear();
                for(var i in _list){
                  if(i.name.toLowerCase().contains(val.toLowerCase()) || i.email.toLowerCase().contains(val.toLowerCase())) {
                    _searchList.add(i);
                  }
                  setState(() {
                    _searchList;
                  });
                }
              },
              autofocus: true,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Name, Email...',
              ),
            ) : const Text('SalesApp Chat'),
            leading: const Icon(Icons.home),
            actions: [
              IconButton(onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                });
              }, icon: Icon(_isSearching ? CupertinoIcons.clear_circled_solid : Icons.search)),
              IconButton(onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(user: ApiServices.me)));
              }, icon: const Icon(Icons.more_vert)),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await ApiServices.auth.signOut();
              await GoogleSignIn().signOut();
            }, child: const Icon(Icons.add_comment),
          ),
          body: StreamBuilder(
            stream: ApiServices.getAllUsers(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                // if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());
                // if some or all data is loaded then show it
                case ConnectionState.active:
                case ConnectionState.done:

                final data = snapshot.data?.docs;
                _list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

                if(_list.isNotEmpty) {
                  return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _isSearching ? _searchList.length : _list.length,
                      itemBuilder: (context, index) {
                        return ChatUserCard(user: _isSearching ? _searchList[index] : _list[index]);
                      }
                  );
                }else{
                  return const Center(child: Text('No Connection Found!', style: TextStyle(fontSize: 20),));
                }
              }
            }
          ),
        ),
      ),
    );
  }
}
