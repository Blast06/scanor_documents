import 'dart:io';

import '/services/ads_service.dart';

import '/consts/consts.dart';
import '/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_compressor/pdf_compressor.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';

class ViewerScreen extends StatefulWidget {
  const ViewerScreen(this.file, {Key? key}) : super(key: key);
  final Map file;
  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.file['extension'].toLowerCase() == 'pdf') {
      return PdfViewerScreen(widget.file);
    } else if (widget.file['extension'].toLowerCase() == 'png') {
      return ImageViewerScreen(widget.file);
    } else if (widget.file['extension'].toLowerCase() == 'txt') {
      return TextViewerScreen(widget.file);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(lang('Not Found')),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          lang('Not Found'),
          style: AppStyles.heading.copyWith(
            color: AppColors.text2,
            fontSize: AppSizes.size22,
          ),
        ),
      ),
    );
  }
}

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen(this.file, {Key? key}) : super(key: key);
  final Map file;

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
      document: PdfDocument.openFile(widget.file['path']),
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
                style: const TextStyle(fontSize: 22),
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
        XFile(widget.file['path']),
      ]);
    } catch (e) {
      dd(e.toString());
    }
  }

  shareCompressPDF() async {
    try {
      final dir = await getTemporaryDirectory();
      final compressPdfFile = File('${dir.path}/${widget.file['name']}.pdf');
      await PdfCompressor.compressPdfFile(
        widget.file['path'],
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

class ImageViewerScreen extends StatefulWidget {
  const ImageViewerScreen(this.file, {Key? key}) : super(key: key);
  final Map file;

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text('${widget.file['extension'].toUpperCase()} Viewer'),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: AppColors.border,
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              File(widget.file['path']),
              width: double.infinity,
              fit: BoxFit.fill,
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
                InkWell(
                  onTap: () async {
                    await Share.shareXFiles([
                      XFile(widget.file['path']),
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
          ),
        ],
      ),
    );
  }
}

class TextViewerScreen extends StatefulWidget {
  const TextViewerScreen(this.file, {Key? key}) : super(key: key);
  final Map file;

  @override
  State<TextViewerScreen> createState() => _TextViewerScreenState();
}

class _TextViewerScreenState extends State<TextViewerScreen> {
  TextEditingController textEditingController = TextEditingController();
  String text = '';
  @override
  void initState() {
    super.initState();
    readText();
  }

  Future readText() async {
    try {
      final file = File(widget.file['path']);
      textEditingController.text = await file.readAsString();
    } catch (e) {
      dd(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(lang('Text Viewer')),
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
                  controller: textEditingController,
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
            BannerAds(),
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
                          ClipboardData(text: text),
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
                                fontSize: AppSizes.size14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        Share.share(text);
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
