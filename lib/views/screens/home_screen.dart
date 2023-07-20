
import '../../utils/helpers.dart';
import '/services/ads_service.dart';
import '/consts/consts.dart';
import '/views/widgets/feature_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'document_screen.dart';
import 'id_card_screen.dart';
import 'ocr_screen.dart';
import 'pdf_merge_screen.dart';
import 'qr_generate_screen.dart';
import 'qr_scanner_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  AppColors.primaryColor,
                  Color.fromRGBO(0, 158, 122, 1),
                ],
              ),
            ),
            height: Get.height - 40,
            width: double.infinity,
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: AppSizes.newSize(10),
                    left: 0,
                    right: 0,
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.houseChimney,
                        color: AppColors.text,
                        size: AppSizes.newSize(4),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(70),
                        topRight: Radius.circular(70),
                      ),
                      child: Container(
                        height: AppSizes.newSize(60),
                        width: double.infinity,
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.only(
                          top: 30,
                          left: 30,
                          right: 30,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            Text(
                              lang('Home'),
                              style: AppStyles.heading.copyWith(
                                color: AppColors.text2,
                                fontSize: AppSizes.newSize(3),
                              ),
                            ),
                            SizedBox(height: AppSizes.newSize(5)),
                            Container(
                              margin: EdgeInsets.only(
                                bottom: AppSizes.newSize(4),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  FeatureWidget(
                                    icon: FontAwesomeIcons.fileContract,
                                    title: "OCR",
                                    callback: () {
                                        Get.to(() => const OcrScreen());
                                      // AdsService.showInterstitialAd(() {
                                      
                                      // });
                                    },
                                  ),
                                  FeatureWidget(
                                    icon: FontAwesomeIcons.idCard,
                                    title: 'ID Card',
                                    callback: () {
                                      Get.to(() => const IdCardScreen());
                                      // AdsService.showInterstitialAd(() {
                                        
                                      // });
                                    },
                                  ),
                                  FeatureWidget(
                                    icon: FontAwesomeIcons.filePdf,
                                    title: "PDF Merge",
                                    callback: () {
                                      //AdsService.showInterstitialAd(() 
                                      //{
                                        Get.to(() => const PdfMergeScreen());
                                      //});
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                bottom: AppSizes.newSize(4),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  FeatureWidget(
                                    icon: FontAwesomeIcons.file,
                                    title: "Document",
                                    callback: () => const DocumentScreen(),
                                  ),
                                  FeatureWidget(
                                    icon: FontAwesomeIcons.marker,
                                    title: "QR Generate",
                                    callback: () {
                                        Get.to(() => const QrGenerateScreen());
                                      //AdsService.showInterstitialAd(() {
                                      
                                      //});
                                    },
                                  ),
                                  FeatureWidget(
                                    icon: FontAwesomeIcons.qrcode,
                                    title: "QR Scan",
                                    callback: () {
                                       Get.to(() => const QrScannerScreen());
                                      // AdsService.showInterstitialAd(() {
                                       
                                      // });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 10,
          left: 20,
          child: SafeArea(
            child: IconButton(
              icon: const Icon(
                Icons.menu,
                color: AppColors.text,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        )
      ],
    );
  }
}
