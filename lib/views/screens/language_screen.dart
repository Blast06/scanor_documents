import 'package:flutter/material.dart';
import '/utils/helpers.dart';
import '/consts/consts.dart';
import '/services/localization_service.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  LanguageScreenState createState() => LanguageScreenState();
}

class LanguageScreenState extends State<LanguageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          lang("Languages"),
          style: const TextStyle(
            color: AppColors.text,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        shrinkWrap: true,
        //controller: _scrollController,
        itemCount: LocalizationService.langs.length,
        itemBuilder: (context, index) {
          var data = LocalizationService.langs[index];

          return LanguageWidget(
            name: data,
            isSelected: data == settingController.currentLanguage.value,
            callback: () {
              settingController.currentLanguage.value = data;
              LocalizationService().changeLocale(data);
            },
          );
        },
      ),
    );
  }
}

class LanguageWidget extends StatelessWidget {
  const LanguageWidget({
    Key? key,
    required this.isSelected,
    required this.name,
    this.callback,
  }) : super(key: key);

  final bool isSelected;
  final String name;
  final VoidCallback? callback;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: callback,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 18,
        ).copyWith(right: 15, left: 15),
        margin: const EdgeInsets.only(left: 15),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 0.2,
              color: AppColors.border,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: AppStyles.text.copyWith(
                fontSize: AppSizes.size16,
                color: AppColors.text2,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                size: AppSizes.size20,
                color: AppColors.text2,
              ),
          ],
        ),
      ),
    );
  }
}
