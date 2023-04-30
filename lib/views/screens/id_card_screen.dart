import 'dart:io';
import 'package:camera/camera.dart';
import '/services/ads_service.dart';
import '/consts/consts.dart';
import '/utils/helpers.dart';
import '/views/dialogs/file_name.dart';
import '/views/widgets/camara_overlay.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class IdCardScreen extends StatefulWidget {
  const IdCardScreen({Key? key}) : super(key: key);

  @override
  State<IdCardScreen> createState() => _IdCardScreenState();
}

class _IdCardScreenState extends State<IdCardScreen> {
  late List<CameraDescription> _cameras;
  CameraController? controller;
  int flashMode = 1;
  List<File> images = [];
  int currentPage = 1;

  @override
  void initState() {
    super.initState();

    onInitCamara();
    //getImage(ImageSource.camera);
  }

  onInitCamara() async {
    _cameras = await availableCameras();
    controller = CameraController(
      _cameras[0],
      ResolutionPreset.ultraHigh,
    );
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            showToast('User denied camera access.');
            break;
          default:
            showToast('Handle other errors.');
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang('ID Card')),
      ),
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: controller != null
            ? Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Stack(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: CameraPreview(
                                controller!,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 3,
                                      horizontal: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      lang(currentPage == 1
                                          ? 'Front Page'
                                          : 'Back Page'),
                                      style: AppStyles.heading.copyWith(
                                        color: AppColors.text,
                                        fontSize: AppSizes.size22,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const CamaraOverlayWidget(
                          padding: 35,
                          aspectRatio: 1.4,
                          color: Color(0x55000000),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    controller?.setFlashMode(FlashMode.off);
                                    setState(() {
                                      flashMode = 1;
                                    });
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(
                                      Icons.flash_off,
                                      color: flashMode == 1
                                          ? AppColors.primaryColor
                                          : AppColors.text,
                                      size: 25,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                InkWell(
                                  onTap: () {
                                    controller?.setFlashMode(FlashMode.auto);
                                    setState(() {
                                      flashMode = 2;
                                    });
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(
                                      Icons.flash_auto,
                                      color: flashMode == 2
                                          ? AppColors.primaryColor
                                          : AppColors.text,
                                      size: 25,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                InkWell(
                                  onTap: () {
                                    controller?.setFlashMode(FlashMode.always);
                                    setState(() {
                                      flashMode = 3;
                                    });
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(
                                      Icons.flash_on,
                                      color: flashMode == 3
                                          ? AppColors.primaryColor
                                          : AppColors.text,
                                      size: 25,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.grey.withOpacity(0.6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          flex: 3,
                          child: InkWell(
                            onTap: () async {
                              File? file = await getImage(ImageSource.gallery);
                              if (file == null) {
                                return;
                              }
                              takeImage(file);
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
                                      fontSize: AppSizes.size14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: InkWell(
                              onTap: () async {
                                XFile? takeFile =
                                    await controller?.takePicture();
                                if (takeFile == null) {
                                  return;
                                }

                                File? cropFile = await cropImage(takeFile.path);
                                if (cropFile == null) {
                                  return;
                                }
                                takeImage(cropFile);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                      width: 5,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (currentPage == 2)
                          Expanded(
                            flex: 3,
                            child: InkWell(
                              onTap: () {
                                restart();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const FaIcon(
                                      FontAwesomeIcons.arrowLeft,
                                      color: AppColors.text,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      lang('Back'),
                                      style: AppStyles.heading.copyWith(
                                        color: AppColors.text.withOpacity(0.7),
                                        fontSize: AppSizes.size14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          const Expanded(
                            flex: 3,
                            child: SizedBox(),
                          ),
                      ],
                    ),
                  ),
                ],
              )
            : const SizedBox(),
      ),
    );
  }

  takeImage(File file) {
    images.add(file);
    if (images.length == 1) {
      currentPage = 2;
      setState(() {});
    } else if (images.length == 2) {
      AdsService.showInterstitialAd(() {
        Get.to(() => IdCardView(images))?.then((value) => restart());
      });
    }
  }

  restart() {
    currentPage = 1;
    images.clear();
    setState(() {});
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

class IdCardView extends StatefulWidget {
  const IdCardView(this.images, {Key? key}) : super(key: key);
  final List<File> images;
  @override
  State<IdCardView> createState() => _IdCardViewState();
}

class _IdCardViewState extends State<IdCardView> {
  ScreenshotController screenshotController = ScreenshotController();
  bool isShowFormat = false;
  bool isPdfLoading = false;
  bool isPngLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang('Id Card ')),
        actions: [
          if (!isShowFormat)
            InkWell(
              onTap: () {
                AdsService.showInterstitialAd(() {
                  isShowFormat = true;
                  setState(() {});
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
          else ...[
            InkWell(
              onTap: () async {
                isPngLoading = true;
                setState(() {});
                File? file = await createImage();
                if (file == null) {
                  return;
                }
                isPngLoading = false;
                setState(() {});
                fileNameDialog('PNG', file.path, 'id_card');
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
                          fontSize: AppSizes.size14,
                          color: AppColors.text,
                          fontWeight: FontWeight.bold,
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
                  fontSize: AppSizes.size14,
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                isPdfLoading = true;
                setState(() {});
                File? file = await createPdf();
                if (file == null) {
                  return;
                }
                isPdfLoading = false;
                setState(() {});
                fileNameDialog('PDF', file.path, 'id_card');
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
                          fontSize: AppSizes.size14,
                          color: AppColors.text,
                          fontWeight: FontWeight.bold,
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
                isShowFormat = false;
                setState(() {});
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
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(),
          ),
          child: Screenshot(
            controller: screenshotController,
            child: Container(
              color: Colors.white,
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.file(
                    widget.images[0],
                    width: double.infinity,
                    height: 170,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 50),
                  Image.file(
                    widget.images[1],
                    width: double.infinity,
                    height: 170,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        width: double.infinity,
        color: Colors.grey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: () async {
                File? file = await createPdf();
                if (file == null) {
                  return;
                }

                await Share.shareXFiles([
                  XFile(file.path),
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
}
