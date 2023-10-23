import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter8/theme/buttons.dart';
import 'package:flutter8/theme/layout.dart';
import 'package:flutter8/theme/spacers.dart';
import 'package:flutter8/theme/text.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreenWidget extends StatefulWidget {
  const LoginScreenWidget({super.key});

  @override
  State<LoginScreenWidget> createState() => _LoginScreenWidgetState();
}

class _LoginScreenWidgetState extends State<LoginScreenWidget> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
    clientId: dotenv.env['FIREBASE_GOOGLE_CLIENT_ID'],
  );
  bool _isLoading = false;

  @override
  void initState() {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) async {
      _isLoading = true;
      setState(() {});

      bool isAuth = account != null;
      if (account != null) {
        isAuth = await _googleSignIn.canAccessScopes(["email"]);
      }
      if (!isAuth) {
        _isLoading = false;
        setState(() {});
        return;
      }
      var authentication = await account!.authentication;
      var googleCredentials =
          GoogleAuthProvider.credential(accessToken: authentication.accessToken, idToken: authentication.idToken);

      await FirebaseAuth.instance.signInWithCredential(googleCredentials);

      if (FirebaseAuth.instance.currentUser != null) {
        if (mounted) {
          context.pop();
        }
      } else {
        _isLoading = false;
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(layoutPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const TitleText("Sign up to Flutter8"),
              const Spacer1(),
              const Spacer1(),
              const Text("To create a post you must signup."),
              const Spacer2(),
              ElevatedLoadingButton(
                onPressed: () => _googleSignIn.signIn(),
                isLoading: _isLoading,
                child: const Text("CONTINUE WITH GOOGLE"),
              ),
              const Spacer2(),
              const Text("More ways to signup is coming soon!"),
            ],
          ),
        ),
      ),
    );
  }
}
