import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../infrastructure/google_api.dart';
import '../repository/mail_summerize.dart';

class SharedGoogleAccount extends ChangeNotifier {
  GoogleSignInAccount? googleAccount;
  bool isAuthorized = false;

  SharedGoogleAccount();

  void onUpdate(GoogleSignInAccount account, bool authorized) {
    googleAccount = account;
    isAuthorized = authorized;
    //notifyListeners();
  }

  Future<void> handleSignIn() async {
    setupGoogleSignInListener((account, authorized) {
      onUpdate(account!, authorized);
    });
    await handleGoogleSignInSilently();
    if (googleAccount == null) {
      await handleGoogleSignIn();
    }
    notifyListeners();
  }

  void handleAuthorizeScopes() {
    handleGoogleAuthorizeScopes((authorized) {
      isAuthorized = authorized;
    }, googleAccount);
  }
}

final googleAccountProvider =
    ChangeNotifierProvider((ref) => SharedGoogleAccount());

class SharedGMailData extends ChangeNotifier {
  List<String>? rawData;
  List<String>? summarizedSchedule;
  SharedGoogleAccount? googleAccount;

  SharedGMailData(this.googleAccount);

  Future<void> fetchMailData(GoogleSignInAccount account) async {
    rawData = await fetchGMailsAsStr(account);
    notifyListeners();
  }

  Future<void> summarizeMailData() async {
    summarizedSchedule = await detectSchedulesFromProcessedTexts(rawData!);
    //notifyListeners();
  }
}

final gmailDataProvider = ChangeNotifierProvider((ref) {
  final googleAccount = ref.watch(googleAccountProvider);
  return SharedGMailData(googleAccount);
});
