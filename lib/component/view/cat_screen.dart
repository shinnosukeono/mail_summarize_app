import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mail_app/component/view/fill_cat.dart';

Widget catScreen() {
  return Scaffold(
    backgroundColor: const Color.fromRGBO(38, 94, 149, 1.0),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          SizedBox(
            height: 50,
            width: 50,
            child:
                LoadingAnimationWidget.inkDrop(color: Colors.white, size: 50),
          ),
          Container(
            padding: const EdgeInsets.only(left: 30, bottom: 20),
            alignment: Alignment.topLeft,
            child: const Text('Loading...',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ),
          Container(
            padding: const EdgeInsets.only(left: 30, right: 30, bottom: 100),
            alignment: Alignment.topLeft,
            child: const Text(
                'このアプリは、メールの要約にAIを利用しています。多数のメールを同時に処理するため、要約が終わるまでに1-2分程度かかります。',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}
