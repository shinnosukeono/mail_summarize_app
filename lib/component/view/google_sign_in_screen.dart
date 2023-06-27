import 'package:flutter/material.dart';

import 'package:mail_app/component/button/google_sign_in_button.dart';
import 'package:mail_app/state/notifier_google_account.dart';

Widget googleSignInScreen(SharedGoogleAccount googleAccount) {
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
}
