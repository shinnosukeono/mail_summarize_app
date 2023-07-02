import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mail_app/component/view/google_sign_in_screen.dart';
import 'package:mail_app/state/notifier_google_account.dart';
import 'package:mail_app/component/view/cat_screen.dart';
import 'package:mail_app/widget/list_presentation.dart';

class StartUpPage extends ConsumerWidget {
  final bool explicit;
  const StartUpPage({super.key, required this.explicit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final googleAccount = ref.watch(googleAccountProvider);
    return Scaffold(
        body: FutureBuilder(
            future: explicit
                ? googleAccount.handleSignInExplicitly()
                : googleAccount.handleSignIn(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                //waiting for sign-in to complete
                return catScreen();
              } else if (snapshot.hasError) {
                return googleSignInScreen(googleAccount);
              } else {
                return const ListPage();
              }
            }));
  }
}
