import 'package:flutter/material.dart';

AppBar header(context, {bool isAppTitle = false, String titleText}) {
  return AppBar(
    automaticallyImplyLeading: false,
    title: Text(
      isAppTitle ? 'SocialApp' : titleText,
      style: TextStyle(
        fontSize: 50.0,
        color: Colors.white,
        fontFamily: 'Signatra',
      ),
    ),
    centerTitle: true,
    backgroundColor: Colors.teal,
  );
}
