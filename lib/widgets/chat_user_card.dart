import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({Key? key}) : super(key: key);

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {},
        child: const ListTile(
          leading: CircleAvatar(child: Icon(Icons.person),),
          title: Text('Demo User'),
          subtitle: Text('Last message', maxLines: 1,),
          trailing: Text('12:00 PM', style: TextStyle(color: Colors.black54),),
        ),
      ),
    );
  }
}
