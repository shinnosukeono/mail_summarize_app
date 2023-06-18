import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../component/button/google_sign_in_button.dart';
import '../component/view/list_tile.dart';
import '../state/notifier_google_account.dart';

class ListPage extends ConsumerWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final googleAccount = ref.watch(googleAccountProvider);
    final gmailData = ref.watch(gmailDataProvider);

    if (googleAccount.googleAccount == null) {
      print('failed to sign in');
      return Scaffold(
          appBar: AppBar(
            title: const Text('google sign in'),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              const Text('You are not currently signed in.'),
              // This method is used to separate mobile from web code with conditional exports.
              // See: component/button/google_sign_in_button.dart
              buildGoogleSignInButton(
                onPressed: googleAccount.handleSignIn,
              ),
            ],
          ));
    } else {
      if (gmailData.rawData == null) {
        gmailData.fetchMailData(googleAccount.googleAccount!);
        return Scaffold(
            appBar: AppBar(
              title: const Text('email loading'),
            ),
            body: CircularProgressIndicator());
      }
      return Scaffold(
          appBar: AppBar(
            title: const Text('email summarizing'),
          ),
          body: FutureBuilder(
              future: gmailData.summarizedScheduleData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final mailData = gmailData.summarizedSchedule;
                  List<dynamic> jsonMailData = [];
                  jsonMailData = jsonDecode(mailData!);
                  jsonMailData.sort((a, b) {
                    DateTime dateA = DateTime.parse(a['ymd']);
                    DateTime dateB = DateTime.parse(b['ymd']);
                    return dateA.compareTo(dateB);
                  });
                  return MailListView(jsonMailData: jsonMailData);
                }
              }));
    }
  }
}

class MailListView extends StatelessWidget {
  final List<dynamic>? jsonMailData;

  MailListView({this.jsonMailData});

  @override
  Widget build(BuildContext context) {
    if (jsonMailData == null || jsonMailData!.isEmpty) {
      return Center(child: Text('No mail data'));
    }

    return ListView.builder(
      itemCount: jsonMailData!.length,
      itemBuilder: (context, index) {
        return buildListTile(jsonMailData![index]['summary'],
            jsonMailData![index]['d'], jsonMailData![index]['dow']);
      },
    );
  }
}
