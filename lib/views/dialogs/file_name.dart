import '../../utils/helpers.dart';
import '/consts/consts.dart';
import '/controllers/file_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> fileNameDialog(
  String extension,
  String path,
  String function,
) async {
  FileController fileController = Get.find();
  TextEditingController textEditingController = TextEditingController();
  int timestamp = DateTime.now().millisecondsSinceEpoch;

  String name = '';
  if (extension.toLowerCase() == 'pdf') {
    name = 'Document_$timestamp';
  } else if (extension.toLowerCase() == 'png') {
    name = 'Image_$timestamp';
  } else if (extension.toLowerCase() == 'txt') {
    name = 'Text_$timestamp';
  }

  textEditingController.text = name;

  return showDialog(
    context: Get.context!,
    builder: (context) {
      return AlertDialog(
        title: Text(
          lang('Creating $extension'),
          style: AppStyles.heading.copyWith(
            color: AppColors.text2,
          ),
        ),
        content: TextField(
          controller: textEditingController,
          style: AppStyles.text.copyWith(
            color: AppColors.text2,
            fontSize: AppSizes.size15,
          ),
          decoration: InputDecoration(
            isDense: true,
            //floatingLabelBehavior: FloatingLabelBehavior.never,

            hintStyle: AppStyles.text.copyWith(
              color: AppColors.text2,
              fontSize: AppSizes.size13,
            ),
            labelText: lang('Enter file name.'),
            labelStyle: AppStyles.text.copyWith(
              color: AppColors.primaryColor,
              fontSize: AppSizes.size14,
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryColor),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryColor),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: Text(
              lang('CANCEL'),
              style: AppStyles.heading.copyWith(
                color: AppColors.primaryColor,
                fontSize: AppSizes.size14,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Map arguments = {
                'extension': extension.toLowerCase(),
                'path': path,
                'name': textEditingController.text,
                'isNameChanege': textEditingController.text != name,
                'function': function,
              };
              fileController.save(arguments);
            },
            child: Text(
              lang('OK'),
              style: AppStyles.heading.copyWith(
                color: AppColors.primaryColor,
                fontSize: AppSizes.size14,
              ),
            ),
          ),
        ],
      );
    },
  );
}
