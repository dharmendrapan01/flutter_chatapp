import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/helper/mydate_util.dart';
import 'package:flutter_chat_app/helper/show_message.dart';
import 'package:image_picker/image_picker.dart';

import '../api/api_services.dart';
import '../main.dart';
import '../modals/user_modal.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ViewProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.user.name),
        ),

        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Joined On: ', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),),
            Text(MyDateUtil.getLastMessageTime(context: context, time: widget.user.createdAt, showYear: true), style: const TextStyle(color: Colors.black87, fontSize: 15),),
          ],
        ),

        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(width: mq.width, height: mq.height * .01,),

                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .1),
                  child: CachedNetworkImage(
                    width: mq.height * .2,
                    height: mq.height * .2,
                    fit: BoxFit.fill,
                    imageUrl: widget.user.image,
                    errorWidget: (context, url, error) => const CircleAvatar(child: Icon(Icons.person),),
                  ),
                ),

                SizedBox(height: mq.height * .01,),

                Text(widget.user.email, style: const TextStyle(color: Colors.black87, fontSize: 16),),

                SizedBox(height: mq.height * .03,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('About: ', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),),
                    Text(widget.user.about, style: const TextStyle(color: Colors.black87, fontSize: 15),),
                  ],
                ),

                SizedBox(height: mq.height * .03,),

              ],
            ),
          ),
        ),
      ),
    );
  }

}
