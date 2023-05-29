import 'dart:io';

import '/services/ads_service.dart';

import '/views/dialogs/file_name.dart';

import '/consts/consts.dart';
import '/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scan/scan.dart';
import 'package:share_plus/share_plus.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({Key? key}) : super(key: key);

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  ScanController controller = ScanController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // QRView(
          //   key: qrKey,
          //   onQRViewCreated: (QRViewController controller) {
          //     setState(() {
          //       this.controller = controller;
          //     });
          //     controller.resumeCamera();

          //     controller.scannedDataStream.listen((scanData) {
          //       print(scanData);
          //     });
          //   },
          //   overlay: QrScannerOverlayShape(
          //     borderColor: AppColors.primaryColor,
          //     borderRadius: 10,
          //     borderLength: 30,
          //     borderWidth: 10,
          //     cutOutSize: 250,
          //   ),
          //   onPermissionSet: (ctrl, permissionStatus) {
          //     if (!permissionStatus) {
          //       showToast('No Permission');
          //     }
          //   },
          // ),
          ScanView(
            controller: controller,
            scanAreaScale: .7,
            scanLineColor: AppColors.primaryColor,
            onCapture: (finalText) {
              controller.pause();
              Get.to(() => QrTextScreen(finalText))?.then((value) {
                  controller.resume();
                });
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              width: double.infinity,
              color: Colors.grey.withOpacity(0.6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () async {
                      File? pickedFile =
                          await getImage(ImageSource.gallery, false);

                      if (pickedFile != null) {
                        String? finalText = await Scan.parse(pickedFile.path);
                        if (finalText != null) {
                          controller.pause();
                          Get.to(() => QrTextScreen(finalText))
                                ?.then((value) {
                              controller.resume();
                            });
                        } else {
                          showToast('No Qr Found', ToastGravity.CENTER);
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.image,
                            color: AppColors.text,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            lang('Gallary'),
                            style: AppStyles.heading.copyWith(
                              color: AppColors.text.withOpacity(0.7),
                              fontSize: AppSizes.size16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      controller.toggleTorchMode();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: FutureBuilder(
                        future: Future.value(true),
                        builder: (context, snapshot) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(
                                snapshot.data.toString() == 'false'
                                    ? Icons.flash_on
                                    : Icons.flash_off,
                                color: AppColors.text,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                lang('Flash'),
                                style: AppStyles.heading.copyWith(
                                  color: AppColors.text.withOpacity(0.7),
                                  fontSize: AppSizes.size16,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.xmark,
                            color: AppColors.text,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            lang('Close'),
                            style: AppStyles.heading.copyWith(
                              color: AppColors.text.withOpacity(0.7),
                              fontSize: AppSizes.size16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QrTextScreen extends StatefulWidget {
  final String text;
  const QrTextScreen(this.text, {Key? key}) : super(key: key);

  @override
  State<QrTextScreen> createState() => _QrTextScreenState();
}

class _QrTextScreenState extends State<QrTextScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          InkWell(
            onTap: () async {
               File? file = await createTxtFile(widget.text);
                if (file == null) {
                  return;
                }
                fileNameDialog('TXT', file.path, 'qr_scan');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 20,
              ),
              child: Text(
                lang('Save'),
                style: AppStyles.text.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.size14,
                ),
              ),
            ),
          )
        ],
      ),
      body: KeyboardVisibilityBuilder(builder: (context, visible) {
        return Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  textAlign: TextAlign.left,
                  initialValue: widget.text,
                  style: TextStyle(
                    fontSize: AppSizes.size18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text2,
                    height: 2,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  expands: true,
                  minLines: null,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
              ),
            ),
            //BannerAds(),
            if (!visible)
              Container(
                height: 80,
                width: double.infinity,
                color: Colors.grey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: () async {
                        Clipboard.setData(
                          ClipboardData(text: widget.text),
                        );
                        showToast('Text copied to clipboard');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.copy,
                              color: AppColors.text,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              lang('Copy'),
                              style: AppStyles.heading.copyWith(
                                color: AppColors.text.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        Share.share(widget.text);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.shareNodes,
                              color: AppColors.text,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              lang('Share'),
                              style: AppStyles.heading.copyWith(
                                color: AppColors.text.withOpacity(0.7),
                                fontSize: AppSizes.size14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
          ],
        );
      }),
    );
  }
}
