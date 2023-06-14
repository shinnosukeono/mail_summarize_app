import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../component/button/google_sign_in_button.dart';
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
              future: gmailData.summarizeMailData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return MailListView(mailData: gmailData.summarizedSchedule);
                }
              }));
    }
  }
}

class MailListView extends StatelessWidget {
  final List<String>? mailData;

  MailListView({this.mailData});

  @override
  Widget build(BuildContext context) {
    if (mailData == null || mailData!.isEmpty) {
      return Center(child: Text('No mail data'));
    }

    return ListView.builder(
      itemCount: mailData!.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(mailData![index]),
        );
      },
    );
  }
}
