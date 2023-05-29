import 'dart:io';
//import '/services/ads_service.dart';
import '/views/dialogs/file_name.dart';
import '/consts/consts.dart';
import '/controllers/setting_controller.dart';
import '/utils/helpers.dart';
import '/views/widgets/feature_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

class OcrScreen extends StatefulWidget {
  const OcrScreen({Key? key}) : super(key: key);

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  SettingController settingController = Get.find();

  File? image;
  String finalText = ' ';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang('Ocr Scanner')),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        //padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.2),
                ),
                child: (image == null)
                    ? Text(
                        lang('No image selected'),
                        style: AppStyles.text.copyWith(
                          fontSize: AppSizes.size18,
                          color: AppColors.text2,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Center(
                        child: Image.file(
                          image!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.fill,
                        ),
                        // child: Image.asset(
                        //   'assets/images/logo.png',
                        //   width: double.infinity,
                        //   height: double.infinity,
                        // ),
                      ),
              ),
            ),
            Container(
              height: 0.5,
              width: double.infinity,
              color: AppColors.border,
            ),
            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    lang('Select Image from'),
                    style: AppStyles.text.copyWith(
                      fontSize: AppSizes.size18,
                      color: AppColors.text2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          getImage(ImageSource.gallery);
                        },
                        child: Container(
                          width: AppSizes.newSize(9),
                          height: AppSizes.newSize(9),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              10,
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
                          child: RadiantGradientMask(
                            child: FaIcon(
                              FontAwesomeIcons.image,
                              color: AppColors.text,
                              size: AppSizes.newSize(4),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSizes.newSize(4.5)),
                      InkWell(
                        onTap: () {
                          getImage(ImageSource.camera);
                        },
                        child: Container(
                          width: AppSizes.newSize(9),
                          height: AppSizes.newSize(9),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              10,
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
                          child: RadiantGradientMask(
                            child: FaIcon(
                              FontAwesomeIcons.camera,
                              color: AppColors.text,
                              size: AppSizes.newSize(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.newSize(5)),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: !isLoading
                          ? const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            )
                          : const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 10,
                            ),
                    ),
                    onPressed: image != null
                        ? () {
                            getText();
                          }
                        : null,
                    child: !isLoading
                        ? Text(
                            lang('Scan Now'),
                            style: AppStyles.text.copyWith(
                              fontSize: AppSizes.size18,
                              color: AppColors.text,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : SizedBox(
                            width: AppSizes.size22,
                            height: AppSizes.size22,
                            child: const CircularProgressIndicator(
                              color: AppColors.text,
                            ),
                          ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  getImage(ImageSource imageSource) async {
    final ImagePicker imagePicker = ImagePicker();
    XFile? xFile;
    if (imageSource == ImageSource.gallery) {
      xFile = await imagePicker.pickImage(source: ImageSource.gallery);
    } else {
      xFile = await imagePicker.pickImage(source: ImageSource.camera);
    }
    image = File(xFile!.path);
    setState(() {});
  }

  Future getText() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    await Future.delayed(1.seconds);
    final inputImage = InputImage.fromFilePath(image!.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText reconizedText =
        await textRecognizer.processImage(inputImage);

    var finalText = '';

    if (reconizedText.blocks.isEmpty) {
      showToast(
        'No text found.',
        ToastGravity.CENTER,
      );
    }

    for (TextBlock block in reconizedText.blocks) {
      //dd(block.text);
      for (TextLine textLine in block.lines) {
        for (TextElement textElement in textLine.elements) {
          finalText = "$finalText ${textElement.text}";
        }

        finalText = '$finalText\n';
      }
    }
    setState(() {
      isLoading = false;
    });
    textRecognizer.close();
    Get.to(() => OcrTextScreen(finalText));
    
  }
}

class OcrTextScreen extends StatefulWidget {
  final String text;
  const OcrTextScreen(this.text, {Key? key}) : super(key: key);

  @override
  State<OcrTextScreen> createState() => _OcrTextScreenState();
}

class _OcrTextScreenState extends State<OcrTextScreen> {
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
              fileNameDialog('TXT', file.path, 'ocr');
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
                                fontSize: AppSizes.size16,
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
                                fontSize: AppSizes.size16,
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


// class OcrScreen extends StatefulWidget {
//   const OcrScreen({Key? key}) : super(key: key);

//   @override
//   OcrScreenState createState() => OcrScreenState();
// }

// class OcrScreenState extends State<OcrScreen> {
//   String imagePath = "asd";
//   File? myImagePath;
//   String finalText = ' ';
//   bool isLoaded = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: FloatingActionButton(onPressed: () {
//         getText(imagePath);
//       }),
//       backgroundColor: Colors.black,
//       body: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const SizedBox(
//               height: 100,
//             ),
//             Container(
//               height: MediaQuery.of(context).size.height * 0.5,
//               width: MediaQuery.of(context).size.width,
//               color: Colors.teal,
//               child: myImagePath != null
//                   ? Image.file(
//                       myImagePath!,
//                       fit: BoxFit.fill,
//                     )
//                   : const Text("This is image section "),
//             ),
//             Center(
//               child: TextButton(
//                 onPressed: () {
//                   getImage();
//                 },
//                 child: Text(
//                   "Pick Image",
//                   style: GoogleFonts.aBeeZee(
//                     fontSize: 30,
//                   ),
//                 ),
//               ),
//             ),
//             if (isLoaded) CircularProgressIndicator(),
//             Text(
//               finalText,
//               style: GoogleFonts.aBeeZee(
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future getText(String path) async {
//     final inputImage = InputImage.fromFilePath(path);
//     final textDetector = GoogleMlKit.vision
//         .textRecognizer(script: TextRecognitionScript.devanagiri);
//     final RecognizedText reconizedText =
//         await textDetector.processImage(inputImage);
//     dd(reconizedText.blocks);
//     for (TextBlock block in reconizedText.blocks) {
//       dd(block.text);
//       for (TextLine textLine in block.lines) {
//         for (TextElement textElement in textLine.elements) {
//           setState(() {
//             finalText = "$finalText ${textElement.text}";
//           });
//         }

//         finalText = '$finalText\n';
//       }
//     }
//   }

//   // this is for getting the image form the gallery
//   void getImage() async {
//     setState(() {
//       isLoaded = true;
//     });
//     final ImagePicker _picker = ImagePicker();
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//     setState(() {
//       myImagePath = File(image!.path);
//       isLoaded = true;
//       imagePath = image.path.toString();
//     });

//     getText(imagePath);
//     setState(() {
//       isLoaded = false;
//     });
//   }
// }