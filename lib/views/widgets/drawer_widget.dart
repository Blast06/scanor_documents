import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '/views/screens/language_screen.dart';
import '/utils/helpers.dart';
import '/consts/consts.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        child: Container(
                          height: 80,
                          width: 80,
                          padding: const EdgeInsets.all(10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                AppColors.primaryColor,
                                Color.fromRGBO(0, 158, 122, 1),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 0,
                                blurRadius: 1,
                                offset: const Offset(0, 1),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Image.asset(
                            'assets/images/splash.jpeg',
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        AppConsts.appName,
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: AppSizes.size16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
                ListTile(
                  leading: const FaIcon(
                    FontAwesomeIcons.bell,
                  ),
                  title: Text(lang('Notification')),
                  trailing: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Obx(() {
                        return Switch(
                          activeColor: AppColors.primaryColor,
                          value: settingController.notification.value,
                          onChanged: (v) {
                            settingController.notification.value = v;
                            writeStorage('notification', v);
                          },
                        );
                      }),
                    ),
                  ),
                ),
                
                ListTile(
                  leading: const FaIcon(
                    FontAwesomeIcons.userShield,
                  ),
                  title: Text(lang('Privacy Police')),
                  onTap: () {
                    launchURL(AppConsts.privacyPolice);
                  },
                ),
                // ListTile(
                //   leading: const FaIcon(
                //     FontAwesomeIcons.newspaper,
                //   ),
                //   title: Text(lang('Terms Conditions')),
                //   onTap: () {
                //     launchURL(AppConsts.termsConditions);
                //   },
                // ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            child: Builder(builder: (context) {
              return Text(
                'Version: ${settingController.version}',
                style: TextStyle(
                  color: AppColors.text2,
                  fontSize: AppSizes.size15,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
