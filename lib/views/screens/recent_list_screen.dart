import '/services/ads_service.dart';

import '/controllers/file_controller.dart';
import '/utils/helpers.dart';
import '/consts/consts.dart';
import '/views/widgets/feature_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'viewer_screen.dart';

class RecentListScreen extends StatefulWidget {
  const RecentListScreen({Key? key}) : super(key: key);

  @override
  State<RecentListScreen> createState() => _RecentListScreenState();
}

class _RecentListScreenState extends State<RecentListScreen> {
  FileController fileController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.white,
      child: Obx(() {
        var files = fileController.files;
        return files.isNotEmpty
            ? ListView.builder(
                itemCount: files.length,
                itemBuilder: (context, index) {
                  Map file = files[index];
                  int timestamp = file['timestamp'];

                  String time = DateFormat('yyyy-MM-dd HH:mm:a').format(
                    DateTime.fromMillisecondsSinceEpoch(timestamp),
                  );
                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                           Get.to(() => ViewerScreen(file));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.primaryColor,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: AppSizes.newSize(8),
                                height: AppSizes.newSize(8),
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
                                    getIcon(file['function']),
                                    color: AppColors.text,
                                    size: AppSizes.newSize(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      file['name'],
                                      style: AppStyles.text.copyWith(
                                        color: AppColors.primaryColor
                                            .withOpacity(0.6),
                                        fontSize: AppSizes.size16,
                                      ),
                                    ),
                                    Text(
                                      time,
                                      style: AppStyles.text.copyWith(
                                        color: AppColors.text2,
                                        fontSize: AppSizes.size16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  fileController.remove(index);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Icon(
                                    Icons.delete,
                                    color: AppColors.text,
                                    size: AppSizes.size18,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              )
            : Center(
                child: Text(
                  lang('No saved files.'),
                  style: AppStyles.text.copyWith(
                    fontSize: AppSizes.size18,
                    color: AppColors.text2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
      }),
    );
  }
}
