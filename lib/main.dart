import 'package:devicelocale/devicelocale.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import '/utils/helpers.dart';
import '/consts/consts.dart';
import '/views/screens/parent_screen.dart';
import '/controllers/setting_controller.dart';
import '/controllers/file_controller.dart';
import '/views/screens/splash_screen.dart';
import 'firebase_options.dart';
import 'services/app_open_service.dart';
import 'services/localization_service.dart';

var logger = Logger();

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.lazyPut(() => AppOpenService());
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  /*await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );*/
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {}
  await GetStorage.init();
  MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(
      testDeviceIds: [
        '58C48A9B2D3201D36081B21975E531A9',
      ],
    ),
  );

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: LocalizationService(),
      locale: Get.deviceLocale,
      //fallbackLocale: const Locale('en', 'US'),
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: AppColors.primaryColor,
        ),
        primaryColor: AppColors.primaryColor,
        fontFamily: GoogleFonts.hind().fontFamily,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: AppColors.primaryColor,
        ),
      ),
      title: AppConsts.appName,
      onGenerateRoute: (settings) {
        final routes = <String, WidgetBuilder>{
          // PsScheduleScreen.route: (BuildContext context) =>
          //     PsScheduleScreen(settings.arguments),
        };
        WidgetBuilder? builder = routes[settings.name];
        return MaterialPageRoute(builder: (context) => builder!(context));
      },
      onInit: () async {
        Get.put(SettingController());
        Get.put(FileController());
       
      },
      home: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  SettingController settingController = Get.find();
  final AppOpenService appOpenService = Get.find();
  var hasNotification = false;
  late Map arguments;

  @override
  void initState() {
    super.initState();
    initNotification();
    
  }

  initNotification() async {
    dd('initNotification');

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      dd(message.notification?.title);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      dd(message.notification?.title);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SplashScreen(),
    );
  }
}

// TODO 
//screenshots 
//add screenshots 
//change the app logo

