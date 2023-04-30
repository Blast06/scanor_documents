import 'dart:io';
import '/services/ads_service.dart';
import 'package:pdf_compressor/pdf_compressor.dart';
import '/consts/consts.dart';
import '/utils/helpers.dart';
import '/views/dialogs/file_name.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code_plus/pretty_qr_code_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:async';

class QrGenerateScreen extends StatefulWidget {
  const QrGenerateScreen({Key? key}) : super(key: key);

  @override
  State<QrGenerateScreen> createState() => _QrGenerateScreenState();
}

class _QrGenerateScreenState extends State<QrGenerateScreen> {
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang('Generate Qrcode')),
      ),
      body: Column(
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
                controller: textEditingController,
                autofocus: true,
                textAlign: TextAlign.left,
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
          Center(
            child: InkWell(
              onTap: () {
                var text = textEditingController.text;
                if (text == '') {
                  showToast('TextField is required.', ToastGravity.CENTER);
                  return;
                }
                AdsService.showInterstitialAd(() {
                  Get.to(() => QrViewScreen(text));
                });
              },
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 20),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 30,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: AppColors.primaryColor,
                ),
                child: Text(
                  lang('Generate'),
                  style: AppStyles.heading.copyWith(
                    color: AppColors.text,
                    fontSize: AppSizes.size22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QrViewScreen extends StatefulWidget {
  const QrViewScreen(this.text, {Key? key}) : super(key: key);
  final String text;
  @override
  State<QrViewScreen> createState() => _QrViewScreenState();
}

class _QrViewScreenState extends State<QrViewScreen> {
  ScreenshotController screenshotController = ScreenshotController();
  bool isShowFormat = false;
  bool isPdfLoading = false;
  bool isPngLoading = false;
  bool isShowShare = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang('Qrcode')),
        actions: [
          if (!isShowFormat)
            InkWell(
              onTap: () {
                AdsService.showInterstitialAd(() {
                  setState(() {
                    isShowFormat = true;
                  });
                });
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
                  ),
                ),
              ),
            )
          else ...[
            InkWell(
              onTap: () async {
                setState(() {
                  isPngLoading = true;
                });
                File? file = await createImage();
                if (file == null) {
                  return;
                }
                setState(() {
                  isPngLoading = false;
                });
                fileNameDialog('PNG', file.path, 'qr_generate');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 10,
                ),
                child: !isPngLoading
                    ? Text(
                        lang('PNG'),
                        style: AppStyles.text.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.bold,
                          fontSize: AppSizes.size14,
                        ),
                      )
                    : const Center(
                        child: SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(
                            color: AppColors.text,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 5,
              ),
              child: Text(
                '|',
                style: AppStyles.text.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                setState(() {
                  isPdfLoading = true;
                });
                File? file = await createPdf();
                if (file == null) {
                  return;
                }
                setState(() {
                  isPdfLoading = false;
                });
                fileNameDialog('PDF', file.path, 'qr_generate');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 10,
                ),
                child: !isPdfLoading
                    ? Text(
                        lang('PDF'),
                        style: AppStyles.text.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.bold,
                          fontSize: AppSizes.size14,
                        ),
                      )
                    : const Center(
                        child: SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(
                            color: AppColors.text,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
              ),
            ),
            InkWell(
              onTap: () async {
                setState(() {
                  isShowFormat = false;
                });
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 10,
                ),
                child: Icon(Icons.close),
              ),
            ),
          ]
        ],
      ),
      body: Center(
        child: Screenshot(
          controller: screenshotController,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(30),
            child: PrettyQrPlus(
              //image: AssetImage('images/twitter.png'),
              typeNumber: 3,
              size: 200,
              data: widget.text,
              errorCorrectLevel: QrErrorCorrectLevel.M,
              roundEdges: false,
            ),
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BannerAds(),
          Container(
            height: 80,
            width: double.infinity,
            color: Colors.grey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (!isShowShare)
                  InkWell(
                    onTap: () async {
                      setState(() {
                        isShowShare = true;
                      });
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
                  )
                else ...[
                  InkWell(
                    onTap: () async {
                      File? pdfFile = await createPdf();
                      if (pdfFile == null) {
                        return;
                      }
                      await Share.shareXFiles([
                        XFile(pdfFile.path),
                      ]);
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
                            lang('Original Size'),
                            style: AppStyles.heading.copyWith(
                              color: AppColors.text.withOpacity(0.7),
                              fontSize: AppSizes.size14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      setState(() {
                        isShowShare = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          FaIcon(
                            FontAwesomeIcons.xmark,
                            color: AppColors.text,
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      compressPDF();
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
                            lang('Compress Size'),
                            style: AppStyles.heading.copyWith(
                              color: AppColors.text.withOpacity(0.7),
                              fontSize: AppSizes.size16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<File?> createImage() async {
    File? file;

    var capturedImage = await screenshotController.capture(
        delay: const Duration(milliseconds: 10));
    file = await uint8ListToFile(capturedImage!);
    if (file == null) {
      return null;
    }

    return file;
  }

  Future<File?> createPdf() async {
    File? file = await createImage();
    if (file == null) {
      return null;
    }
    var pdf = pw.Document();

    final img = pw.MemoryImage(file.readAsBytesSync());
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context contex) {
          return pw.Center(child: pw.Image(img));
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final pdfFile = File('${dir.path}/document.pdf');
    await pdfFile.writeAsBytes(await pdf.save());

    return pdfFile;
  }

  compressPDF() async {
    try {
      File? pdfFile = await createPdf();
      if (pdfFile == null) {
        return null;
      }
      final dir = await getTemporaryDirectory();
      final compressPdfFile = File('${dir.path}/compress_document.pdf');
      await PdfCompressor.compressPdfFile(
        pdfFile.path,
        compressPdfFile.path,
        CompressQuality.HIGH,
      );

      await Share.shareXFiles([
        XFile(compressPdfFile.path),
      ]);
    } catch (e) {
      dd(e.toString());
    }
  }
}
