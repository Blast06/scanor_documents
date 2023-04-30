// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '/consts/consts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

getHeight(context, percentage) {
  double height = MediaQuery.of(context).size.height;
  return height * percentage / 100;
}

getWidth(context, percentage) {
  double width = MediaQuery.of(context).size.width;
  return width * percentage / 100;
}

launchURL(url) async {
  Uri uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    dd('Could not launch $uri');
  }
}

showToast(String message, [ToastGravity gravity = ToastGravity.BOTTOM]) {
  if (message != '') {
    Fluttertoast.showToast(
      msg: lang(message),
      toastLength: Toast.LENGTH_LONG,
      gravity: gravity,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.white,
      textColor: AppColors.text2,
      fontSize: 14.0,
    );
  }
}

showSnackBar(String message, [int duration = 5, callback]) {
  if (!kDebugMode && message == 'Server error! Please try again.') {
    return;
  }
  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: Colors.grey[800],
    behavior: SnackBarBehavior.floating,
    duration: Duration(seconds: duration),
    action: callback != null
        ? SnackBarAction(
            label: 'Refresh',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
              callback();
            },
          )
        : null,
  );

  ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
}

Future<File?> getImage(ImageSource source, [bool withCrop = true]) async {
  final pickedFile = await ImagePicker().pickImage(source: source);

  if (pickedFile == null) {
    return null;
  }

  if (withCrop) return cropImage(pickedFile.path);

  return File(pickedFile.path);
}

Future<List<XFile?>?> getMuliableImage() async {
  List<XFile>? pickedFiles = await ImagePicker().pickMultiImage();

  if (pickedFiles == null) {
    return null;
  }

  return pickedFiles;
}

Future<File?> cropImage(String path) async {
  final croppedFile = await ImageCropper().cropImage(
    sourcePath: path,
    compressFormat: ImageCompressFormat.png,
    compressQuality: 100,
    aspectRatioPresets: [
      CropAspectRatioPreset.ratio3x2,
    ],
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: AppColors.primaryColor,
        toolbarWidgetColor: AppColors.text,
        initAspectRatio: CropAspectRatioPreset.ratio3x2,
        lockAspectRatio: false,
      ),
      IOSUiSettings(
        title: 'Crop Image',
      ),
    ],
  );
  if (croppedFile == null) {
    return null;
  }

  return File(croppedFile.path);
}

Future<List<String>> getFiles([
  FileType type = FileType.custom,
  bool allowMultiple = true,
]) async {
  List<PlatformFile>? paths;
  try {
    paths = (await FilePicker.platform.pickFiles(
      type: type,
      allowMultiple: allowMultiple,
      onFileLoading: (FilePickerStatus status) => dd(status),
      allowedExtensions: ['pdf'],
    ))
        ?.files;
  } on PlatformException catch (e) {
    dd('Unsupported operation$e');
  } catch (e) {
    dd(e.toString());
  }
  if (paths != null) {
    return paths.map((e) => e.path!).toList();
  }
  return [];
}

Future<File?> uint8ListToFile(Uint8List uint8list) async {
  try {
    final tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/image.png').create();
    file.writeAsBytesSync(uint8list);

    return file;
  } catch (e) {
    dd(e);
  }

  return null;
}

Future<File?> createTxtFile(String content) async {
  try {
    final tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/file.txt').create();
    file.writeAsString(content);

    return file;
  } catch (e) {
    dd(e);
  }

  return null;
}

Future<bool> requestPermission(Permission permission) async {
  var status = await permission.request();

  return status.isGranted;
}

getRandom() {
  var random = Random.secure();
  var values = List<int>.generate(20, (i) => random.nextInt(255));
  return base64Encode(values);
}

IconData getIcon(function) {
  IconData iconData = FontAwesomeIcons.houseChimney;
  if (function == 'ocr') {
    iconData = FontAwesomeIcons.fileContract;
  } else if (function == 'id_card') {
    iconData = FontAwesomeIcons.idCard;
  } else if (function == 'pdf') {
    iconData = FontAwesomeIcons.filePdf;
  } else if (function == 'document') {
    iconData = FontAwesomeIcons.file;
  } else if (function == 'qr_generate') {
    iconData = FontAwesomeIcons.marker;
  } else if (function == 'qr_scan') {
    iconData = FontAwesomeIcons.qrcode;
  }

  return iconData;
}

readStorage(key) {
  var box = GetStorage();
  return box.read(key);
}

writeStorage(key, value) {
  var box = GetStorage();
  box.write(key, value);
}

lang(String text) {
  return text.tr;
}

dd(object) {
  if (kDebugMode) {
    print(object);
  }
}
