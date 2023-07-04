import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mail_app/component/view/google_sign_in_screen.dart';
import 'package:mail_app/state/notifier_google_account.dart';
import 'package:mail_app/component/view/cat_screen.dart';
import 'package:mail_app/widget/list_presentation.dart';

/*
 * This widget is for doing some initial setups.
 * The app never returns here until the user signs in again.
 */
class StartUpPage extends ConsumerWidget {
  final bool explicit;
  const StartUpPage({super.key, required this.explicit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final googleAccount = ref.watch(googleAccountProvider);
    final gmailData = ref.watch(gmailDataProvider);
    return Scaffold(
        body: FutureBuilder(future: () async {
      if (explicit) {
        await googleAccount.handleSignInExplicitly();
      } else {
        await googleAccount.handleSignIn();
      }
      await gmailData.init(googleAccount.googleAccount!);
    }(), builder: (BuildContext context, AsyncSnapshot snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        //waiting for sign-in to complete
        return catScreen();
      } else if (snapshot.hasError) {
        print(snapshot.error);
        return googleSignInScreen(googleAccount);
      } else {
        // gmailData.init(googleAccount.googleAccount!);
        return const ListPage();
      }
    }));
  }
}
