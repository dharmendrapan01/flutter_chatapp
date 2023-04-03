import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/modals/user_modal.dart';
import 'package:flutter_chat_app/screens/view_profile_screen.dart';

import '../../main.dart';

class ProfileDialog extends StatelessWidget {
  final ChatUser user;
  const ProfileDialog({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: mq.width *.6, height: mq.height * .35,
        child: Stack(
        children: [

          // user profile picture
          Positioned(
            top: mq.height * .075,
            left: mq.width * .1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(mq.height * .25),
              child: CachedNetworkImage(
                width: mq.width * .5,
                fit: BoxFit.cover,
                imageUrl: user.image,
                errorWidget: (context, url, error) => const CircleAvatar(child: Icon(Icons.person),),
              ),
            ),
          ),

          // user name
          Positioned(
              left: mq.width * .04,
              top: mq.height * .02,
              width: mq.width * .55,
              child: Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),)),

          // info button
          Positioned(
            right: 8,
            top: 6,
            child: MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ViewProfileScreen(user: user)));
                },
                minWidth: 0,
                padding: const EdgeInsets.all(0),
                shape: const CircleBorder(),
                child: const Icon(Icons.info_outline, color: Colors.blue, size: 30,)
            ),
          ),
        ],
      ),),
    );
  }
}
