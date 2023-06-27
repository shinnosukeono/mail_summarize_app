import 'dart:io';
import 'dart:io' show Platform;
import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:http/http.dart' as http;

import 'package:google_sign_in/google_sign_in.dart';

/// The scopes required by the google api.
const List<String> googleAPIScopes = <String>[
  'email',
  'https://mail.google.com/',
  'https://www.googleapis.com/auth/contacts.readonly',
];

String defineGoogleAPIClientId() {
  final str = kIsWeb
      ? dotenv.get('GOOGLE_API_KEY_WEB')
      : (Platform.isIOS
          ? dotenv.get('GOOGLE_API_KEY_IOS')
          : dotenv.get('GOOGLE_API_KEY_DESKTOP'));
  return str;
}

final googleAPIClientId = defineGoogleAPIClientId();

var urlGetGmailMessagesList = (final int maxResults) {
  return 'https://www.googleapis.com/gmail/v1/users/me/messages?maxResults=$maxResults';
};

var urlGetGmailMessage = (final String msgId) {
  return 'https://gmail.googleapis.com/gmail/v1/users/me/messages/$msgId?format=full';
};

// the number of emails fetched at a time
const maxResults = 10;

class ListEmails {
  const ListEmails({
    required this.id,
    required this.threadId,
    required this.mimeType,
    required this.rawText,
  });

  final String id;
  final String threadId;
  final String mimeType;
  final String rawText;
}

GoogleSignIn googleSignIn = GoogleSignIn(
  clientId: googleAPIClientId,
  scopes: googleAPIScopes,
  //forceCodeForRefreshToken: true,
);

// This is the on-click handler for the Sign In button that is rendered by Flutter.
//
// On the web, the on-click handler of the Sign In button is owned by the JS
// SDK, so this method can be considered mobile only.
Future<void> handleGoogleSignIn() async {
  try {
    // Starts the interactive sign-in process.
    await googleSignIn.signIn();
  } catch (error) {
    debugPrint('Error signing in: $error');
  }
}

// In the web, googleSignIn.signInSilently() triggers the One Tap UX.
//
// It is recommended by Google Identity Services to render both the One Tap UX
// and the Google Sign In button together to "reduce friction and improve
// sign-in rates" ([docs](https://developers.google.com/identity/gsi/web/guides/display-button#html)).

//Attempts to sign in a previously authenticated user without interaction.
Future<void> handleGoogleSignInSilently() => googleSignIn.signInSilently();

Future<void> handleGoogleSignOut() => googleSignIn.disconnect();

// Prompts the user to authorize `scopes`.
//
// This action is **required** in platforms that don't perform Authentication
// and Authorization at the same time (like the web).
//
// On the web, this must be called from an user interaction (button click).
Future<void> handleGoogleAuthorizeScopes(
    void Function(bool isAuthorized) update,
    GoogleSignInAccount? currentUser) async {
  bool isAuthorized = await googleSignIn.requestScopes(googleAPIScopes);

  if (isAuthorized) {
    unawaited(fetchGoogleEmails(currentUser!));
  }

  update(isAuthorized);
}

void setupGoogleSignInListener(
    void Function(GoogleSignInAccount? account, bool isAuthorized) onUpdate) {
  googleSignIn.onCurrentUserChanged
      .listen((GoogleSignInAccount? account) async {
    // In mobile, being authenticated means being authorized...
    bool isAuthorized = (account != null);
    // However, in the web...
    // check if the authenticated user has granted access to all the specified scopes
    if (kIsWeb && account != null) {
      isAuthorized = await googleSignIn.canAccessScopes(googleAPIScopes);
    }

    if (isAuthorized) {
      unawaited(fetchGoogleEmails(account));
    }

    // callback function (should be defined in StatefulWidget)
    onUpdate(account, isAuthorized);
  });
}

// fetch emails and returns the list of raw texts of the emails.
// the number of emails fetched is specified by 'maxResults'.
Future<List<ListEmails>> fetchGoogleEmails(user) async {
  final headers = await user.authHeaders;
  final response = await http.get(
    Uri.parse(urlGetGmailMessagesList(maxResults)),
    headers: headers,
  );

  if (response.statusCode == HttpStatus.ok) {
    List<ListEmails> listRawTexts = [];
    final messages = jsonDecode(response.body)['messages'];
    for (final msg in messages) {
      final response = await http.get(
        Uri.parse(urlGetGmailMessage(msg['id'])),
        headers: headers,
      );

      final decoded = jsonDecode(response.body);
      final id = decoded['id'];
      final threadId = decoded['threadId'];
      final payload = decoded['payload'];
      final parts = payload['parts'];
      String? decodedData;
      late String partType;

      if (parts != null) {
        for (var part in parts) {
          final partData = part['body'];
          partType = part['mimeType'];
          if (partData['size'] > 0 || partData['attachmentId'] != null) {
            //final attachmentId = partData['attachmentId'];
            final data = partData['data'];
            decodedData = utf8.decode(base64Url.decode(data));
            if (partType == 'text/html') break;
          }
        }
        //print(decodedData);
        if (decodedData != null) {
          listRawTexts.add(ListEmails(
              id: id,
              threadId: threadId,
              mimeType: partType,
              rawText: decodedData));
        }
      } else {
        final data = payload['body']['data'];
        final partType = payload['mimeType'];
        decodedData = utf8.decode(base64Url.decode(data));
        //print(decodedData);
        listRawTexts.add(ListEmails(
            id: id,
            threadId: threadId,
            mimeType: partType,
            rawText: decodedData));
      }
    }
    return listRawTexts;
  } else {
    throw Exception('Failed to fetch emails');
  }
}
