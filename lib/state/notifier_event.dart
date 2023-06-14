import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../repository/mail_summerize.dart';
import 'notifier_google_account.dart';

class SharedMailData extends ChangeNotifier {
  List<String>? mailData;

  SharedMailData();

  Future<void> fetchMailData(GoogleSignInAccount account) async {
    mailData = await fetchGMailsAsStr(account);
    notifyListeners();
  }
}

final mailDataProvider = ChangeNotifierProvider((ref) {
  final googleAccount = ref.watch(googleAccountProvider);
  return SharedMailData(googleAccount);
});
