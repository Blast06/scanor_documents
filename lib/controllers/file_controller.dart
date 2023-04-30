import 'dart:convert';
import 'dart:io';

import '/utils/helpers.dart';
import '/views/screens/parent_screen.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';

class FileController extends GetxController {
  RxBool idLoading = true.obs;
  RxList<Map> files = <Map>[].obs;

  loadFiles() {
    var box = GetStorage();
    var boxFiles = box.read('files');
    if (boxFiles != null) {
      jsonDecode(boxFiles).forEach((item) {
        files.add(item);
      });
    }

    sort();
  }

  save(Map arguments) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;

    File tempFile = File(arguments['path']);
    try {
      final tempDir = await getApplicationDocumentsDirectory();
      File file = await File(
        '${tempDir.path}/${arguments['name']}_$timestamp.${arguments['extension'].toLowerCase()}',
      ).create();
      file.writeAsBytesSync(tempFile.readAsBytesSync());

      arguments['path'] = file.path;
      arguments['timestamp'] = timestamp;

      files.add(arguments);
      sort();

      var box = GetStorage();
      box.write('files', jsonEncode(files));

      showToast('File save successfully.');

      Get.off(() => const ParentScreen(page: 1));
    } catch (e) {
      showToast(e.toString());
    }
  }

  remove(int index) {
    files.removeAt(index);
    sort();

    var box = GetStorage();
    box.write('files', jsonEncode(files));
  }

  sort() {
    files.sort((a, b) {
      return b['timestamp'].compareTo(a['timestamp']);
    });
    files = files;
  }

  @override
  void onInit() {
    super.onInit();

    loadFiles();
  }
}
