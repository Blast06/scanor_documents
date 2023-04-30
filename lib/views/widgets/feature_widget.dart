import 'package:quick_scanner/utils/helpers.dart';

import '/consts/consts.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';

class FeatureWidget extends StatelessWidget {
  const FeatureWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.callback,
  }) : super(key: key);
  final IconData icon;
  final String title;
  final Callback callback;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => callback(),
      child: SizedBox(
        width: AppSizes.newSize(10),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: AppSizes.newSize(10),
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
                  icon,
                  color: AppColors.text,
                  size: AppSizes.newSize(4),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              lang(title),
              style: AppStyles.heading.copyWith(
                color: AppColors.text2,
                fontSize: AppSizes.size12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RadiantGradientMask extends StatelessWidget {
  const RadiantGradientMask({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const RadialGradient(
        center: Alignment.center,
        radius: 0.5,
        colors: [
          AppColors.primaryColor,
          Color.fromRGBO(0, 158, 122, 1),
        ],
        tileMode: TileMode.mirror,
      ).createShader(bounds),
      child: child,
    );
  }
}
