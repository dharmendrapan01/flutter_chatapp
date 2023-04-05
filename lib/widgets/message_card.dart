import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_app/api/api_services.dart';
import 'package:flutter_chat_app/helper/mydate_util.dart';
import 'package:flutter_chat_app/helper/show_message.dart';
import 'package:gallery_saver/gallery_saver.dart';

import '../main.dart';
import '../modals/message_modal.dart';

class MessageCard extends StatefulWidget {
  final MessageModal message;

  const MessageCard({Key? key, required this.message}) : super(key: key);

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = ApiServices.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        _showBottomSheet(isMe);
      },
      child: isMe ? _greenMessage() : _blueMessage()
    );
  }

  // sender or another user message
  Widget _blueMessage() {
    // update last read message if sender and receiver are different
    if (widget.message.read.isEmpty) {
      ApiServices.updateMessageReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image ? mq.width * .01 : mq.width * .02),
            margin: EdgeInsets.symmetric(
                vertical: mq.width * .03, horizontal: mq.height * .01),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 221, 245, 255),
                border: Border.all(color: Colors.blue),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10))),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                : ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: CachedNetworkImage(
                    imageUrl: widget.message.msg,
                    placeholder: (context, url) => const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2,),
                    ),
                    errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
                ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent),
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        )
      ],
    );
  }

  // our or user messages
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: mq.width * .03,
            ),
            // double tick blue icon for message read
            widget.message.read.isNotEmpty
                ? const Icon(
                    Icons.done_all_rounded,
                    color: Colors.blue,
                    size: 20,
                  )
                : const Icon(
                    Icons.done_all_rounded,
                    color: Colors.grey,
                    size: 20,
                  ),
            const SizedBox(
              width: 2,
            ),
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image ? mq.width * .01 : mq.width * .02),
            margin: EdgeInsets.symmetric(
                vertical: mq.width * .03, horizontal: mq.height * .01),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 218, 255, 176),
                border: Border.all(color: Colors.lightGreen),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10))),
            child: widget.message.type == Type.text
                ? Text(
              widget.message.msg,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
              )
                : ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: CachedNetworkImage(
                  imageUrl: widget.message.msg,
                  placeholder: (context, url) => const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2,),
                  ),
                  errorWidget: (context, url, error) => const CircleAvatar(
                  child: Icon(
                    Icons.image,
                    size: 70,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


  // bottom sheet for modifying message details
  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20))),
        context: context,
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(vertical: mq.height * .015, horizontal: mq.width * .4),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              widget.message.type == Type.text ? // copy option
              _OptionItem(icon: const Icon(Icons.copy_all_rounded, color: Colors.blue, size: 26,), name: 'Copy Text', onTap: () async {
                await Clipboard.setData(ClipboardData(text: widget.message.msg)).then((value) {
                  Navigator.pop(context);
                  DialogsMessage.showSnackbar(context, 'Text Copied!');
                });
              }) : // copy option
              _OptionItem(icon: const Icon(Icons.download_rounded, color: Colors.blue, size: 26,), name: 'Save Image', onTap: () async {
                try{
                  await GallerySaver.saveImage(widget.message.msg, albumName: 'SalesChat').then((success) {
                    Navigator.pop(context);
                    if(success != null && success) DialogsMessage.showSnackbar(context, 'Image Successfully Saved!');
                  });
                }catch(e){
                  log('Error while saving image: $e');
                }
              }),

              // separator or divider
              if(isMe)
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.height * .04,
              ),

              // edit option
              if(widget.message.type == Type.text && isMe)
              _OptionItem(icon: const Icon(Icons.edit, color: Colors.blue, size: 26,), name: 'Edit Message', onTap: () {
                Navigator.pop(context);
                _showMessageUpdateDialog();
              }),

              // delete option
              if(isMe)
              _OptionItem(icon: const Icon(Icons.delete_forever, color: Colors.red, size: 26,), name: 'Delete Message', onTap: () async {
                await ApiServices.deleteMessage(widget.message).then((value) {
                  Navigator.pop(context);
                });
              }),

              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.height * .04,
              ),

              // sent time
              _OptionItem(icon: const Icon(Icons.remove_red_eye, color: Colors.blue), name: 'Sent At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}', onTap: () {}),

              // read time
              _OptionItem(icon: const Icon(Icons.remove_red_eye, color: Colors.green), name: widget.message.read.isEmpty ? 'Read At: Not Seen Yet' : 'Read At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}', onTap: () {}),
            ],
          );
        }
    );
  }

  void _showMessageUpdateDialog() {
    String updateMsg = widget.message.msg;
    showDialog(context: context, builder: (_) => AlertDialog(
      contentPadding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: const [
          Icon(Icons.message, color: Colors.blue, size: 28,),
          Text(' Update Message'),
        ],
      ),
      content: TextFormField(
        initialValue: updateMsg,
        maxLines: null,
        onChanged: (value) => updateMsg = value,
        decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
      ),
      actions: [
        MaterialButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.blue, fontSize: 16),),
        ),
        MaterialButton(
          onPressed: () {
            Navigator.pop(context);
            ApiServices.updateMessage(widget.message, updateMsg);
          },
          child: const Text('Update', style: TextStyle(color: Colors.blue, fontSize: 16),),
        ),
      ],
    ));
  }

}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const _OptionItem({required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(left: mq.width * .05, top: mq.height * .015, bottom: mq.height * .015),
        child: Row(
          children: [
            icon,
            Flexible(child: Text('   $name', style: const TextStyle(fontSize: 15, color: Colors.black54, letterSpacing: 0.5),)),
          ],
        ),
      ),
    );
  }
}

