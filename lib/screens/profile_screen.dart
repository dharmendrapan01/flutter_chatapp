import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/auth/login_screen.dart';
import 'package:flutter_chat_app/helper/show_message.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../api/api_services.dart';
import '../main.dart';
import '../modals/user_modal.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  List<ChatUser> list = [];
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.redAccent,
          onPressed: () async {
            DialogsMessage.showProgressbar(context);

            await ApiServices.updateActiveStatus(false);

            // sign out from app
              await ApiServices.auth.signOut().then((value) async {
              await GoogleSignIn().signOut().then((value) {
                // for hiding progress bar screen
                Navigator.pop(context);

                // for closing to home screen
                Navigator.pop(context);

                ApiServices.auth = FirebaseAuth.instance;

                // replacing home screen with login screen
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              });
            });
          },
          label: const Text('Logout'),
          icon: const Icon(Icons.logout),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(width: mq.width, height: mq.height * .01,),

                  Stack(
                    children: [
                      _image != null ?

                     // local image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * .1),
                        child: Image.file(
                          File(_image!),
                          width: mq.height * .2,
                          height: mq.height * .2,
                          fit: BoxFit.fill,
                        ),
                      )
                      :
                      // image from server
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

                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          onPressed: () {
                            _showBottomSheet();
                          },
                          color: Colors.white,
                          shape: const CircleBorder(),
                          elevation: 1,
                          child: const Icon(Icons.edit, color: Colors.blue,),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: mq.height * .01,),

                  Text(widget.user.email, style: const TextStyle(color: Colors.black54, fontSize: 16),),

                  SizedBox(height: mq.height * .05,),

                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => ApiServices.me.name = val ?? '',
                    validator: (val) => val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person, color: Colors.blue,),
                      hintText: 'Ex. Varun Sing',
                      label: const Text('Name'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  SizedBox(height: mq.height * .03,),

                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (val) => ApiServices.me.about = val ?? '',
                    validator: (val) => val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.info_outline, color: Colors.blue),
                      hintText: 'Ex. Feeling Happy',
                      label: const Text('About'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  SizedBox(height: mq.height * .03,),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(shape: const StadiumBorder(), minimumSize: Size(mq.width * .4, mq.height * .055)),
                    onPressed: () {
                      if(_formKey.currentState!.validate()){
                        _formKey.currentState!.save();
                        ApiServices.updateUserInfo().then((value) {
                          DialogsMessage.showSnackbar(context, 'Profile Updated Successfully!');
                        });
                      }
                    },
                    icon: const Icon(Icons.edit, size: 28,),
                    label: const Text('UPDATE', style: TextStyle(fontSize: 16),),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20))),
      context: context,
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: [
            SizedBox(height: mq.height * .02,),

            const Text('Pick Profile Picture', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),

            SizedBox(height: mq.height * .02,),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    fixedSize: Size(mq.width * .2, mq.height * .1),
                  ),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image.
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                      if(image != null){
                        // log('Image Path : ${image.path} -- MimeType: ${image.mimeType}');
                        setState(() {
                          _image = image.path;
                        });
                        ApiServices.updateProfilePicture(File(_image!));
                        // ignore: use_build_context_synchronously
                        Navigator.of(context);
                      }
                    },
                    child: Image.asset('images/addimg.png'),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    fixedSize: Size(mq.width * .2, mq.height * .1),
                  ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    // Pick an image.
                    final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                    if(image != null){
                      // log('Image Path : ${image.path}');
                      setState(() {
                        _image = image.path;
                      });
                      ApiServices.updateProfilePicture(File(_image!));
                      // ignore: use_build_context_synchronously
                      Navigator.of(context);
                    }
                  },
                  child: Image.asset('images/camera.png'),
                ),
              ],
            )
          ],
        );
      }
    );
  }
}
