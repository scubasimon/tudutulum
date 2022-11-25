import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tudu/firebase_options.dart';
import 'package:tudu/viewmodels/authentication_viewmodel.dart';
import 'package:tudu/views/onboard/onboard_view.dart';

import 'generated/l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // if (kDebugMode) {
  //   await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  // } else {
  //
  // }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthenticationViewModel())
      ],
      child: MaterialApp(
        theme: ThemeData(
          highlightColor: Colors.transparent,
        ),
        localizationsDelegates: const [
          S.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: const OnboardView(),
      ),
    );
  }
}