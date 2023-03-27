import 'package:flutter/material.dart';

class DialogsMessage {

  static void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue.withOpacity(.8),
        behavior: SnackBarBehavior.floating,
    ));
  }

  static void showProgressbar(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          return const Center(child: CircularProgressIndicator());
        }
    );
  }

}