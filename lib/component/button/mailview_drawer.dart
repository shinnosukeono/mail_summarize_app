import 'package:flutter/material.dart';

import 'package:mail_app/widget/list_presentation.dart';

Widget buildDrawerMailListButton(BuildContext context) {
  return Drawer(
    child: ListView(
      // padding: EdgeInsets.zero,
      children: <Widget>[
        const ListTile(
          title: Text('フォルダ'),
        ),
        ListTile(
          leading: const Icon(Icons.calendar_month_outlined),
          title: const Text('予定（すべて）'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const ListPageSimple(
                onlyImportantFlag: false,
              );
            }));
          },
        ),
        ListTile(
          leading: const Icon(Icons.crisis_alert),
          title: const Text('予定（重要）'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const ListPageSimple(
                onlyImportantFlag: true,
              );
            }));
          },
        ),
        const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Divider(
            color: Colors.grey,
            height: 0,
          ),
        ),
        const ListTile(
          title: Text('アカウント'),
        ),
        ListTile(
          title: const Text('メニュー3'),
          onTap: () {
            // メニュー3がタップされたときの処理を書く
          },
        ),
        ListTile(
          title: const Text('メニュー4'),
          onTap: () {
            // メニュー4がタップされたときの処理を書く
          },
        ),
      ],
    ),
  );
}
