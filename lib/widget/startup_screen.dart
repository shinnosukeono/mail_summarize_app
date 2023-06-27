import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mail_app/component/view/google_sign_in_screen.dart';
import 'package:mail_app/state/notifier_google_account.dart';
import 'package:mail_app/component/view/cat_screen.dart';
import 'package:mail_app/widget/list_presentation.dart';

class StartUpPage extends ConsumerWidget {
  const StartUpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final googleAccount = ref.watch(googleAccountProvider);
    return Scaffold(
        body: FutureBuilder(
            future: googleAccount.handleSignIn(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                //waiting for sign-in to complete
                return catScreen();
              } else if (snapshot.hasError) {
                return googleSignInScreen(googleAccount);
              } else {
                /*
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ListPage()),
                  );
                });
                return Container();
                */
                return const ListPage();
              }
            }));
  }
}
