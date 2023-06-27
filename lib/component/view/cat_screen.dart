import 'package:flutter/material.dart';

Widget catScreen() {
  return Center(
    child: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fitHeight,
          image: AssetImage('assets/images/cat.jpg'),
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.5, 0.7, 0.95],
            colors: [
              Colors.black12,
              Colors.black54,
              Colors.black87,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
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
              padding: const EdgeInsets.only(left: 30, bottom: 100),
              alignment: Alignment.topLeft,
              child: const Text('写真の説明文。写真の説明文。写真の説明文。写真の説明文。写真の説明文。写真の説明文。',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                      color: Colors.white)),
            ),
          ],
        ),
      ),
    ),
  );
}
