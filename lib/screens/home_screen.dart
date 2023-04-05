import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_app/helper/show_message.dart';
import 'package:flutter_chat_app/screens/profile_screen.dart';
import 'package:flutter_chat_app/widgets/chat_user_card.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../api/api_services.dart';
import '../main.dart';
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
            onPressed: () {
              _addChatUserDialog();
            }, child: const Icon(Icons.add_comment),
          ),
          body: StreamBuilder(
            stream: ApiServices.getMyUsersId(),

            //get id of only known users
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
              //if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());

              //if some or all data is loaded then show it
                case ConnectionState.active:
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: ApiServices.getAllUsers(snapshot.data?.docs.map((e) => e.id).toList() ?? []),

                    //get only those user, who's ids are provided
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                      //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                        // return const Center(
                        //     child: CircularProgressIndicator());

                        //if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                              ?.map((e) => ChatUser.fromJson(e.data()))
                              .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                itemCount: _isSearching
                                    ? _searchList.length
                                    : _list.length,
                                padding: EdgeInsets.only(top: mq.height * .01),
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return ChatUserCard(
                                      user: _isSearching
                                          ? _searchList[index]
                                          : _list[index]);
                                });
                          } else {
                            return const Center(
                              child: Text('No Connections Found!',
                                  style: TextStyle(fontSize: 20)),
                            );
                          }
                      }
                    },
                  );
              }
            },
          ),
        ),
      ),
    );
  }

  // for adding a new chat user
  void _addChatUserDialog() {
    String email = '';
    showDialog(context: context, builder: (_) => AlertDialog(
      contentPadding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: const [
          Icon(Icons.person_add, color: Colors.blue, size: 28,),
          Text('  Add User'),
        ],
      ),
      content: TextFormField(
        maxLines: null,
        onChanged: (value) => email = value,
        decoration: InputDecoration(
          hintText: 'Email Id',
          prefixIcon: const Icon(Icons.email, color: Colors.blue,),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
      ),
      actions: [
        MaterialButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.blue, fontSize: 16),),
        ),

        // add button
        MaterialButton(
          onPressed: () async {
            Navigator.pop(context);
            if(email.isNotEmpty) {
              await ApiServices.addChatUser(email).then((value) {
                if(!value){
                  DialogsMessage.showSnackbar(context, 'User does not exist!');
                }
            });
            }
          },
          child: const Text('Add', style: TextStyle(color: Colors.blue, fontSize: 16),),
        ),
      ],
    ));
  }

}
