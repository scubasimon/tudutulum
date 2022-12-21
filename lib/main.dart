import 'dart:convert';
import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tudu/consts/urls/URLConst.dart';
import 'package:tudu/firebase_options.dart';
import 'package:tudu/models/param.dart' as p;
import 'package:tudu/repositories/deal/deal_repository.dart';
import 'package:tudu/services/notification/notification.dart';
import 'package:tudu/viewmodels/authentication_viewmodel.dart';
import 'package:tudu/viewmodels/map_screen_viewmodel.dart';
import 'package:tudu/viewmodels/setting_viewmodel.dart';
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
import 'consts/color/Colors.dart';
import 'localization/app_localization.dart';
import 'localization/language_constants.dart';
import 'generated/l10n.dart';
import 'package:localstore/localstore.dart';
import 'package:background_location_tracker/background_location_tracker.dart' as BackgroundLocation;

Future<void> main() async {
  await S.load(const Locale.fromSubtags(languageCode: 'en')); // mimic localization delegate init

  runZonedGuarded<Future<void>>(() async {

    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await PrefUtil.init();
    PrefUtil.setValue(StrConst.isWhatTuduDataBinded, false);
    PrefUtil.setValue(StrConst.isEventDataBinded, false);
    PrefUtil.setValue(StrConst.isDataBinded, false);

    // if (kDebugMode) {
    //   await _connectToFirebaseEmulator();
    // }

    await initPurchase();

    await BackgroundLocation.BackgroundLocationTrackerManager.initialize(
      backgroundCallback,
      config: const BackgroundLocation.BackgroundLocationTrackerConfig(
        loggingEnabled: true,
        androidConfig: BackgroundLocation.AndroidConfig(
          notificationIcon: 'explore',
          trackingInterval: Duration(seconds: 4),
          distanceFilterMeters: null,
        ),
        iOSConfig: BackgroundLocation.IOSConfig(
          activityType: BackgroundLocation.ActivityType.FITNESS,
          distanceFilterMeters: null,
          restartAfterKill: true,
        ),
      ),
    );

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent));
      runApp(MultiProvider(
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
          ),
          ChangeNotifierProvider(
            create: (_) => MapScreenViewModel(),
          ),
          ChangeNotifierProvider(
            create: (_) => SettingViewModel(),
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

@pragma('vm:entry-point')
void backgroundCallback() {
  BackgroundLocation.BackgroundLocationTrackerManager.handleBackgroundUpdated((data) async {
    await PrefUtil.init();
    final lastTime = PrefUtil.getValue(StrConst.lastTime, 0) as int;
    if (lastTime != 0 && DateTime.now().millisecondsSinceEpoch - lastTime < 60000) {
      return;
    }

    PrefUtil.setValue(StrConst.lastTime, DateTime.now().millisecondsSinceEpoch);
    final currentString = PrefUtil.getValue(StrConst.lastLocation, "") as String;
    if (currentString.isNotEmpty) {
      var map = json.decode(currentString) as Map<String, dynamic>;
      var lat = map["lat"] as double;
      var lon = map["lon"] as double;
      final distance = Geolocator.distanceBetween(lat, lon, data.lat, data.lon);
      if (distance <= 1000) {
        return;
      } else {
        PrefUtil.preferences.remove(StrConst.lastLocation);
      }

    }

    await S.load(const Locale.fromSubtags(languageCode: 'en'));
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

     try {
       var result = await DealRepositoryImpl()
           .getDeals(p.Param(refresh: true, order: p.Order.distance), filterDistance: 1000);
       if (result.isNotEmpty) {
         final lastDeal = result.last;
         final lastLocation = json.encode({"lat": lastDeal.site.locationLat!, "lon": lastDeal.site.locationLon!});
         PrefUtil.setValue(StrConst.lastLocation, lastLocation);
         await NotificationServiceImpl().initializePlatform();
         await NotificationServiceImpl().showLocalNotification(id: 0, title: S.current.deal_near_by_title, body: S.current.deal_near_by_body);
       }

     } catch (e) {
       print(e);
     }
  });
}

Future initPurchase() async {
  PurchasesConfiguration configuration;
  Purchases.setDebugLogsEnabled(true);
  if (Platform.isAndroid) {
    configuration = PurchasesConfiguration("appl_CPoQEtilwBpuWuWaHLkymHMzaTw");
  } else {
    configuration = PurchasesConfiguration("appl_CPoQEtilwBpuWuWaHLkymHMzaTw");
  }
  await Purchases.configure(configuration);
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
    Provider.of<MapScreenViewModel>(context, listen: true);
    Provider.of<SettingViewModel>(context, listen: true);
    if (_locale == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AuthenticationViewModel()),
          ChangeNotifierProvider(create: (context) => SettingViewModel()),
        ],
        child: MaterialApp(
          theme: ThemeData(
            highlightColor: Colors.transparent,
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: ColorStyle.darkLabel,
              selectionColor: ColorStyle.darkLabel,
              selectionHandleColor: ColorStyle.darkLabel,
            ),
          ),
          // theme: FlexThemeData.dark(scheme: FlexScheme.mandyRed),
          // // The Mandy red, dark theme.
          // darkTheme: FlexThemeData.light(scheme: FlexScheme.mandyRed),
          // // Use dark or light theme based on system setting.
          // themeMode: ThemeMode.system,
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
