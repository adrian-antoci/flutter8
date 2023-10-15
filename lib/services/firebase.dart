import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> firebaseInit() async {
  bool alreadyInitialised = false;
  try {
    alreadyInitialised = Firebase.apps.isNotEmpty;
  } catch (ex) {}

  if (alreadyInitialised) return;

  final firebaseOptions = FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY']!,
      authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN'],
      projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
      storageBucket: dotenv.env['FIREBASE_BUCKET'],
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER']!,
      appId: dotenv.env['FIREBASE_APP_ID']!);

  await Firebase.initializeApp(options: firebaseOptions);
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider(dotenv.env['FIREBASE_RECAPTCHA']!),
  );
}
