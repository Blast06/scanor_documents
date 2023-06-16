

import '../../utils/helpers.dart';
import '/views/widgets/drawer_widget.dart';

import '/services/ads_service.dart';
import '/services/app_open_service.dart';

import '/views/screens/recent_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

import '/consts/consts.dart';
import 'home_screen.dart';

class ParentScreen extends StatefulWidget {
  const ParentScreen({
    Key? key,
    this.page = 0,
  }) : super(key: key);
  final int page;

  @override
  ParentScreenState createState() => ParentScreenState();
}

class ParentScreenState extends State<ParentScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AppLifecycleReactor _appLifecycleReactor;

  int _selectedIndex = 0;

  void _onItemTapped(int index) async {
    if (index == 2) {
      if (GetPlatform.isAndroid) {
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        Share.share(
            '${AppConsts.appName} \n \n AppLink : https://play.google.com/store/apps/details?id=${packageInfo.packageName}',
            subject: 'Look what we made!');
      } else {
        Share.share('${AppConsts.appName} \n \n AppLink : ',
            subject: 'Look what we made!');
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  void initState() {
    _selectedIndex = widget.page;
    super.initState();

    AdsService.createInterstitialAd();
    Future.delayed(
      2.seconds,
      () {
        AppOpenService appOpenService = AppOpenService()..loadAd();
        _appLifecycleReactor =
            AppLifecycleReactor(appOpenAdManager: appOpenService);

        _appLifecycleReactor.listenToAppStateChanges();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.primaryColor,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: _selectedIndex == 1
            ? AppBar(
                elevation: 0,
                backgroundColor: AppColors.primaryColor,
                title: Text(
                  lang('Recent List'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                centerTitle: true,
              )
            : null,
        backgroundColor: AppColors.primaryColor,
        drawer: const DrawerWidget(),
        body: IndexedStack(
          index: _selectedIndex,
          children: const [
            HomeScreen(),
            RecentListScreen(),
          ],
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //BannerAds(),
            BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.houseChimneyUser),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.file),
                  label: '',
                ),
                // BottomNavigationBarItem(
                //   icon: FaIcon(FontAwesomeIcons.share),
                //   label: '',
                // ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: AppColors.primaryColor,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              onTap: _onItemTapped,
            ),
          ],
        ),
      ),
    );
  }
}
