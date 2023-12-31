import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter8/theme/buttons.dart';
import 'package:flutter8/theme/responsive.dart';
import 'package:flutter8/theme/spacers.dart';
import 'package:flutter8/theme/text.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class WelcomeScreenWidget extends StatefulWidget {
  const WelcomeScreenWidget({super.key});

  @override
  State<WelcomeScreenWidget> createState() => _WelcomeScreenWidgetState();
}

class _WelcomeScreenWidgetState extends State<WelcomeScreenWidget> {
  bool _isLoading = false;

  void _onContinue() async {
    _isLoading = true;
    setState(() {});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setBool("is_terms_agreed", true);
    if (mounted) {
      context.go("/home");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(10),
          constraints: isMobile(context) ? null : const BoxConstraints(maxWidth: 550),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const TitleText("Welcome to"),
              const Spacer2(),
              SvgPicture.asset('assets/logo.svg', height: 70),
              const Spacer2(),
              const TitleText("An open source project"),
              const Spacer1(),
              const Spacer1(),
              _termsWidget(context),
              const Spacer2(),
              ElevatedLoadingButton(
                onPressed: () => _onContinue(),
                isLoading: _isLoading,
                child: const Text("CONTINUE"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _termsWidget(BuildContext context) {
    TextStyle linkStyle = const TextStyle(color: Colors.pinkAccent);
    TextStyle normalStye = const TextStyle(color: Colors.white, height: 1.2);
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: normalStye,
        children: <TextSpan>[
          const TextSpan(text: 'Checkout this project on '),
          TextSpan(
              text: 'Github',
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () => launchUrlString('https://github.com/adrian-antoci/flutter8')),
          const TextSpan(text: '.\n\nBy clicking Continue, you agree that have read and agree with the '),
          TextSpan(
              text: 'Privacy Policy',
              style: linkStyle,
              recognizer: TapGestureRecognizer()..onTap = () => launchUrlString(dotenv.env['PRIVACY_POLICY_URL']!)),
          const TextSpan(text: '. '),
        ],
      ),
    );
  }
}
