import '/consts/consts.dart';
import 'package:flutter/material.dart';

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({Key? key}) : super(key: key);

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('Soon'),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Soon',
          style: AppStyles.heading.copyWith(
            color: AppColors.text2,
            fontSize: AppSizes.size22,
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(onPressed: () async {
      //   try {
      //     final ImagePicker _picker = ImagePicker();
      //     final XFile? pickedFile = await _picker.pickImage(
      //       source: ImageSource.gallery,
      //     );
      //     print(pickedFile);
      //   } catch (e) {
      //     print(e);
      //   }
      // }),
    );
  }
}
