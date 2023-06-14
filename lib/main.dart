import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:mail_app/repository/mail_summerize.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'component/button/google_sign_in_button.dart';
import 'infrastructure/google_api.dart';
import 'infrastructure/openai_api.dart';

import 'widget/list_presentation.dart';

Future<void> main() async {
  await dotenv.load();
  OpenAI.apiKey = dotenv.get('OPENAI_API_KEY');
  runApp(const ProviderScope(
    child: MaterialApp(
      title: 'Google Sign In',
      home: ListPage(),
    ),
  ));
}

/// The SignInDemo app.
class SignInDemo extends StatefulWidget {
  ///
  const SignInDemo({super.key});

  @override
  State createState() => _SignInDemoState();
}

class _SignInDemoState extends State<SignInDemo> {
  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false; // has granted permissions?

  @override
  void initState() {
    super.initState();
    setupGoogleSignInListener((account, isAuthorized) {
      setState(() {
        _currentUser = account;
        _isAuthorized = isAuthorized;
      });
    });

    handleGoogleSignInSilently();
  }

  Widget _buildBody() {
    final GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      // The user is Authenticated
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ListTile(
            leading: GoogleUserCircleAvatar(
              identity: user,
            ),
            title: Text(user.displayName ?? ''),
            subtitle: Text(user.email),
          ),
          const Text('Signed in successfully.'),
          if (_isAuthorized) ...<Widget>[
            // The user has Authorized all required scopes
            ElevatedButton(
              onPressed: () => fetchGoogleEmails(user),
              child: Text('REFRESH'),
            ),
            ElevatedButton(
              onPressed: () async {
                detectSchedulesFromRawTexts(await fetchGoogleEmails(user))
                    .then((results) {
                  print(results);
                });
              },
              child: Text('SUMMERIZE'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListPage()),
                );
              },
              child: Text('CALENDAR'),
            ),
          ],
          if (!_isAuthorized) ...<Widget>[
            // The user has NOT Authorized all required scopes.
            // (Mobile users may never see this button!)
            const Text('Additional permissions needed to read your contacts.'),
            ElevatedButton(
              onPressed: () => handleGoogleAuthorizeScopes((isAuthorized) {
                setState(() {
                  _isAuthorized = isAuthorized;
                });
              }, _currentUser),
              child: const Text('REQUEST PERMISSIONS'),
            ),
          ],
          const ElevatedButton(
            onPressed: handleGoogleSignOut,
            child: Text('SIGN OUT'),
          ),
        ],
      );
    } else {
      // The user is NOT Authenticated
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text('You are not currently signed in.'),
          // This method is used to separate mobile from web code with conditional exports.
          // See: component/button/google_sign_in_button.dart
          buildGoogleSignInButton(
            onPressed: handleGoogleSignIn,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Mail App'),
      ),
      body: _buildBody(),
      drawer: Drawer(
        child: ListView(
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Settings'),
            ),
            ListTile(
              title: Text('Settings'),
              trailing: Icon(Icons.arrow_forward_ios),
            )
          ],
        ),
      ),
    );
  }
}
