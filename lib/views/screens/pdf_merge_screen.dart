import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_compressor/pdf_compressor.dart';
import 'package:pdf_merger/pdf_merger.dart';
import 'package:pdfx/pdfx.dart';
import '/views/dialogs/file_name.dart';
import 'package:share_plus/share_plus.dart';
import '/consts/consts.dart';
import '/services/ads_service.dart';
import '/utils/helpers.dart';

class PdfMergeScreen extends StatefulWidget {
  const PdfMergeScreen({Key? key}) : super(key: key);

  @override
  State<PdfMergeScreen> createState() => _PdfMergeScreenState();
}

class _PdfMergeScreenState extends State<PdfMergeScreen> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang('Pdf Merge')),
      ),
      body: Center(
        child: InkWell(
          onTap: onClick,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 25,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: AppColors.primaryColor,
            ),
            child: !isLoading
                ? Text(
                    lang('Select Pdf Files'),
                    style: AppStyles.heading.copyWith(
                      color: AppColors.text,
                      fontSize: AppSizes.size20,
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    child: const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.text,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
          ),
        ),
      ),
      bottomNavigationBar: BannerAds(),
    );
  }

  onClick() async {
    List<String> paths = await getFiles();

    if (paths.isEmpty) return;
    setState(() {
      isLoading = true;
    });

    try {
      final dir = await getTemporaryDirectory();
      final pdfFile = File('${dir.path}/merge_document.pdf');
      MergeMultiplePDFResponse response = await PdfMerger.mergeMultiplePDF(
          paths: paths, outputDirPath: pdfFile.path);

      setState(() {
        isLoading = false;
      });
      if (response.status == "success") {
        AdsService.showInterstitialAd(() {
          Get.to(() => PdfViewerScreen(pdfFile.path));
        });
      }
    } on PlatformException {
      dd('Failed to get platform version.');
    }
  }
}

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen(this.path, {Key? key}) : super(key: key);
  final String path;

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final ScrollController controller = ScrollController();
  bool isLoading = true;
  late PdfControllerPinch _pdfControllerPinch;
  bool isShowShare = false;

  @override
  void initState() {
    super.initState();

    _pdfControllerPinch = PdfControllerPinch(
      document: PdfDocument.openFile(widget.path),
      initialPage: 1,
    );
  }

  @override
  void dispose() {
    _pdfControllerPinch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text(lang('Pdf Viewer')),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.navigate_before),
            onPressed: () {
              _pdfControllerPinch.previousPage(
                curve: Curves.ease,
                duration: const Duration(milliseconds: 100),
              );
            },
          ),
          PdfPageNumber(
            controller: _pdfControllerPinch,
            builder: (_, loadingState, page, pagesCount) => Container(
              alignment: Alignment.center,
              child: Text(
                '$page/${pagesCount ?? 0}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.navigate_next),
            onPressed: () {
              _pdfControllerPinch.nextPage(
                curve: Curves.ease,
                duration: const Duration(milliseconds: 100),
              );
            },
          ),
          InkWell(
            onTap: () async {
              AdsService.showInterstitialAd(() async {
                fileNameDialog('PDF', widget.path, 'pdf');
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
                  fontSize: AppSizes.size14,
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
      body: Container(
        color: AppColors.background,
        child: PdfViewPinch(
          builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
            options: const DefaultBuilderOptions(),
            documentLoaderBuilder: (_) => const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            ),
            pageLoaderBuilder: (_) => const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            ),
            errorBuilder: (_, error) => Center(
              child: Text(
                error.toString(),
                style: AppStyles.text.copyWith(
                  fontSize: AppSizes.size18,
                  color: AppColors.text2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          controller: _pdfControllerPinch,
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
                      sharePDF();
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
                      shareCompressPDF();
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
                              fontSize: AppSizes.size14,
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

  sharePDF() async {
    try {
      await Share.shareXFiles([
        XFile(widget.path),
      ]);
    } catch (e) {
      dd(e.toString());
    }
  }

  shareCompressPDF() async {
    try {
      final dir = await getTemporaryDirectory();
      final compressPdfFile = File('${dir.path}/compress_document.pdf');
      await PdfCompressor.compressPdfFile(
        widget.path,
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
