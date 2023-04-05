import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chat_app/modals/message_modal.dart';
import 'package:flutter_chat_app/modals/user_modal.dart';
import 'package:http/http.dart';

class ApiServices {
  // for firebase authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud store database
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  // for accessing cloud storage in firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // return current user
  static User get user => auth.currentUser!;

  // for accessing firebase messaging (Push Notification)
  static FirebaseMessaging FMessaging = FirebaseMessaging.instance;

  static Future<void> getFirebaseMessagingToken() async {
    await FMessaging.requestPermission();
    await FMessaging.getToken().then((t) {
      if(t != null){
        me.pushToken = t;
        // log('Push Token : $t');
      }
    });

    // for handling foreground message
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   log('Got a message whilst in the foreground!');
    //   log('Message data: ${message.data}');
    //
    //   if (message.notification != null) {
    //     log('Message also contained a notification: ${message.notification}');
    //   }
    // });
  }

  static Future<void> sendPushNotification(ChatUser chatUser, String msg) async {
    try{
      final body = {
        "to":chatUser.pushToken,
        "notification": {
          "title": chatUser.name,
          "body": msg,
          "android_channel_id": "chats",
          "data": {
            "some_data" : "User Id: ${me.id}",
          },
        }
      };
      var response = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: 'key=AAAADioxA_A:APA91bE5jdJfFsQs3UEgHGPVNDamuoWsvJzAu4XnkT-7GRyUQlHL-1ErALsAWpfkaw1-bwQBIYXR2Vth4hUQ8cXR2N36eUZACORtk0rHafw3_FIow_hgHOneq69NGMOWxvz7ftd45F9F'
          },
          body: jsonEncode(body));
      // log('Response status: ${response.statusCode}');
      // log('Response body: ${response.body}');
    }catch(e){
      log('\nsendPushNotificationE: $e');
    }
  }

  // for storing self information
  static late ChatUser me;

  // for checking if user exist or not
  static Future<bool> userExists() async {
    return (await fireStore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .get())
        .exists;
  }

  // for adding an chat user for our conversation
  static Future<bool> addChatUser(String email) async {
    final data = await fireStore.collection('users').where('email', isEqualTo: email).get();
    // log('data: ${data.docs}');
    if(data.docs.isNotEmpty && data.docs.first.id != user.uid){
      // user exist
      // log('user exists: ${data.docs.first.data()}');
      fireStore.collection('users').doc(user.uid).collection('my_users').doc(data.docs.first.id).set({});
      return true;
    }else{
      // user does not exist
      return false;
    }
  }

  // for getting current user info
  static Future<void> getSelfInfo() async {
    await fireStore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get()
        .then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();

        // for setting user status to active
        ApiServices.updateActiveStatus(true);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
        image: user.photoURL.toString(),
        about: "Hey I'm using SalesApp Chat",
        name: user.displayName.toString(),
        createdAt: time,
        id: user.uid,
        isOnline: false,
        lastActive: time,
        pushToken: '',
        email: user.email.toString());
    return await fireStore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // for getting id's of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return fireStore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    log('\nUserIds: $userIds');

    return fireStore
        .collection('users')
        .where('id',
        whereIn: userIds.isEmpty
            ? ['']
            : userIds) //because empty list throws an error
    // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }


  // for updating user information
  static Future<void> sendFirstMessage(ChatUser chatUser, String msg, Type type) async {
    await fireStore.collection('users').doc(chatUser.id).collection('my_users').doc(user.uid).set({}).then((value) => sendMessage(chatUser, msg, type));
  }


  // for updating user information
  static Future<void> updateUserInfo() async {
    await fireStore.collection('users').doc(auth.currentUser!.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(ChatUser chatUser) {
    return fireStore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    fireStore
    .collection('users')
    .doc(user.uid).update({
      'is_online' : isOnline,
      'last_active' : DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token' : me.pushToken,
    });
  }

  // update profile picture of user
  static Future<void> updateProfilePicture(File file) async {
    // getting image file extension
    final ext = file.path.split('.').last;
    log('Extension : $ext');

    // storage file reference with path
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transfered : ${p0.bytesTransferred / 1000} kb');
    });

    // updating image in firestore database
    me.image = await ref.getDownloadURL();
    await fireStore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({'image': me.image});
  }

  ///**************************** Chat Screen Related Apis ***********************

  //useful for getting conversation id
  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return fireStore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // for sending message
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    // message sending time
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    // message to send
    final MessageModal message = MessageModal(
        msg: msg,
        toId: chatUser.id,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time);

    final ref = fireStore
        .collection('chats/${getConversationId(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) => sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
  }

  static Future<void> updateMessageReadStatus(MessageModal message) async {
    fireStore
        .collection('chats/${getConversationId(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return fireStore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    // getting image file extension
    final ext = file.path.split('.').last;

    // storage file reference with path
    final ref = storage.ref().child(
        'images/${getConversationId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transfered : ${p0.bytesTransferred / 1000} kb');
    });

    // updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }


  // delete message
  static Future<void> deleteMessage(MessageModal message) async {
    await fireStore
        .collection('chats/${getConversationId(message.toId)}/messages/')
        .doc(message.sent)
        .delete();
    if(message.type == Type.image) await storage.refFromURL(message.msg).delete();
  }

  // update message
  static Future<void> updateMessage(MessageModal message, String updatedMsg) async {
    await fireStore
        .collection('chats/${getConversationId(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }
}
