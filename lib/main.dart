import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tudu/consts/urls/URLConst.dart';
import 'package:tudu/firebase_options.dart';
import 'package:tudu/viewmodels/authentication_viewmodel.dart';
import 'package:tudu/viewmodels/what_tudu_article_content_detail_viewmodel.dart';
import 'package:tudu/views/login/login_view.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tudu/utils/pref_util.dart';
import 'package:tudu/consts/strings/str_const.dart';
import 'package:tudu/viewmodels/home_viewmodel.dart';
import 'package:tudu/viewmodels/what_tudu_site_content_detail_viewmodel.dart';
import 'package:tudu/viewmodels/what_tudu_viewmodel.dart';
import 'package:tudu/views/home/home_view.dart';
import 'package:tudu/views/onboard/onboard_view.dart';
import 'localization/app_localization.dart';
import 'localization/language_constants.dart';
import 'generated/l10n.dart';

Future<void> main() async {
  await S.load(const Locale.fromSubtags(languageCode: 'en')); // mimic localization delegate init

  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    PrefUtil.init();

    // if (kDebugMode) {
    //   await _connectToFirebaseEmulator();
    // }

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
        .then((_) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark
          .copyWith(statusBarColor: Colors.transparent));
      runApp(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => HomeViewModel(),
              ),
              ChangeNotifierProvider(
                create: (_) => WhatTuduViewModel(),
              ),
              ChangeNotifierProvider(
                create: (_) => WhatTuduSiteContentDetailViewModel(),
              ),
              ChangeNotifierProvider(
                create: (_) => WhatTuduArticleContentDetailViewModel(),
              )
            ],
            child: Builder(builder: (context) {
              return const MyApp();
            }),
          ));
    });
  }, (error, stackTrace) => print(error.toString() + stackTrace.toString()));
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

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale(StrConst.englishLanguageCode);

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<HomeViewModel>(context, listen: true);
    Provider.of<WhatTuduViewModel>(context, listen: true);
    Provider.of<WhatTuduArticleContentDetailViewModel>(context, listen: true);
    Provider.of<WhatTuduSiteContentDetailViewModel>(context, listen: true);
    if (_locale == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AuthenticationViewModel())
        ],
        child: MaterialApp(
          theme: ThemeData(
            highlightColor: Colors.transparent,
          ),
          debugShowCheckedModeBanner: false,
          locale: _locale,
          supportedLocales: const [
            Locale(StrConst.englishLanguageCode, StrConst.englishCountryCode),
          ],
          localizationsDelegates: const [
            AppLocalization.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale?.languageCode &&
                  supportedLocale.countryCode == locale?.countryCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
          routes: {
            URLConsts.onboard: (context) => const OnboardView(),
            URLConsts.home: (context) => const HomeView(pageIndex: 0),
            URLConsts.login: (context) => const LoginView(),
          },
          home: _endpoint(),
        ),
      );
    }
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
          return const HomeView(pageIndex: 0);
        }
      },
    );
  }
}