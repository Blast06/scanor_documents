// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:io';
import 'dart:math';

import 'package:circular_menu/circular_menu.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
//import '/services/ads_service.dart';
import '/consts/consts.dart';
import '/utils/helpers.dart';
import '/views/dialogs/file_name.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_compressor/pdf_compressor.dart';
import 'package:share_plus/share_plus.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({Key? key}) : super(key: key);

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  GlobalKey<CircularMenuState> key = GlobalKey<CircularMenuState>();
  List<XFile> images = [];
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang('Document')),
        actions: [
          InkWell(
            onTap: () {
              setState(() {
                images.clear();
              });
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 20,
              ),
              child: Icon(
                Icons.delete,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
        ),
        child: images.isNotEmpty
            ? GridView.builder(
                padding: const EdgeInsets.only(top: 10),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: images.length,
                itemBuilder: (BuildContext context, index) {
                  return Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: AppColors.border,
                            width: 0.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(images[index].path),
                            width: double.infinity,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              images.removeAt(index);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Icon(
                              Icons.delete,
                              color: AppColors.text,
                              size: AppSizes.size20,
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                },
              )
            : Center(
                child: Text(
                  lang('No image selected'),
                  style: AppStyles.text.copyWith(
                    fontSize: AppSizes.size14,
                    color: AppColors.text2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
      floatingActionButton: CircularMenu(
        alignment: Alignment.bottomRight,
        startingAngleInRadian: 1.05 * pi,
        endingAngleInRadian: 1.45 * pi,
        toggleButtonSize: 30,
        toggleButtonColor: AppColors.primaryColor,
        key: key,
        items: [
          CircularMenuItem(
            icon: FontAwesomeIcons.images,
            onTap: () async {
              List<XFile?>? pickImages = await getMuliableImage();
              if (pickImages == null) {
                return;
              }
              for (var element in pickImages) {
                images.add(element!);
              }

              setState(() {});
            },
            color: Colors.green,
            iconColor: Colors.white,
          ),
          CircularMenuItem(
            icon: FontAwesomeIcons.camera,
            onTap: () async {
              File? takeFile = await getImage(ImageSource.camera);
              if (takeFile == null) {
                return;
              }
              XFile xFile = XFile(takeFile.path);
              images.add(xFile);

              setState(() {});
            },
            color: Colors.orange,
            iconColor: Colors.white,
          ),
        ],
      ),
      bottomNavigationBar: images.isNotEmpty
          ? Container(
              height: 70,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Center(
                child: InkWell(
                  onTap: () {

                    Get.to(() => DocmentViewScreen(images));
                    
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: AppColors.primaryColor,
                    ),
                    child: Text(
                      lang('Next'),
                      style: AppStyles.text.copyWith(
                        fontSize: AppSizes.size14,
                        color: AppColors.text,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class DocmentViewScreen extends StatefulWidget {
  const DocmentViewScreen(this.images, {Key? key}) : super(key: key);

  final List<XFile> images;

  @override
  State<DocmentViewScreen> createState() => _DocmentViewScreenState();
}

class _DocmentViewScreenState extends State<DocmentViewScreen> {
  final ScrollController controller = ScrollController();
  bool isShowShare = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang("PDF")),
        actions: [
          InkWell(
            onTap: () async {
              File file = await createFile();
              fileNameDialog('PDF', file.path, 'document');
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
      backgroundColor: Colors.grey.shade100,
      body: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 5,
        ),
        child: DraggableScrollbar.semicircle(
          labelTextBuilder: (offset) {
            final int currentItem = (controller.hasClients
                    ? (controller.offset /
                            controller.position.maxScrollExtent *
                            widget.images.length)
                        .floor()
                    : 0) +
                1;

            return Text("$currentItem");
          },
          labelConstraints: const BoxConstraints.tightFor(
            width: 80.0,
            height: 30.0,
          ),
          controller: controller,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 10),
            controller: controller,
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: AppSizes.newSize(50),
                    margin: const EdgeInsets.only(
                      left: 5,
                      right: 5,
                      bottom: 10,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Image.file(
                      File(widget.images[index].path),
                    ),
                  ),
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      height: 30,
                      width: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        (index + 1).toString(),
                        style: AppStyles.heading.copyWith(
                          color: AppColors.text,
                          fontSize: AppSizes.size14,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
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
                  File? pdfFile = await createFile();

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
    );
  }

  Future<File> createFile() async {
    var pdf = pw.Document();

    widget.images.forEach((element) async {
      var file = File(element.path);
      final img = pw.MemoryImage(file.readAsBytesSync());
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context contex) {
            return pw.Center(child: pw.Image(img));
          },
        ),
      );
    });

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/document.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  compressPDF() async {
    try {
      final dir = await getTemporaryDirectory();
      File pdfFile = await createFile();
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
