import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tudu/consts/urls/URLConst.dart';
import 'package:tudu/firebase_options.dart';
import 'package:tudu/viewmodels/authentication_viewmodel.dart';
import 'package:tudu/views/home/home_view.dart';
import 'package:tudu/views/login/login_view.dart';
import 'package:tudu/views/onboard/onboard_view.dart';

import 'generated/l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kDebugMode) {
    // await _connectToFirebaseEmulator();
  }
  runApp(const MyApp());
}

Future _connectToFirebaseEmulator() async {
  final localHostString = Platform.isAndroid ? '10.0.2.2' : 'localhost';

  FirebaseFirestore.instance.settings = Settings(
    host: '$localHostString:8080',
    sslEnabled: false,
    persistenceEnabled: false,
  );

  await FirebaseAuth.instance.useAuthEmulator(localHostString, 9099);
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
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          S.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        routes: {
          URLConsts.onboard: (context) => const OnboardView(),
          URLConsts.home: (context) => const HomeView(),
          URLConsts.login: (context) => const LoginView(),
        },
        home: _endpoint(),
      ),
    );
  }

  Widget _endpoint() {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (BuildContext context, snapshot) {
        if (FirebaseAuth.instance.currentUser == null) {
          var first = snapshot.data?.getBool("open_first");
          if (first == null || first) {
            return const OnboardView();
          } else {
            return const LoginView();
          }
        } else {
          return const HomeView();
        }
      },
    );
  }
}