import '/consts/consts.dart';
import 'package:flutter/material.dart';

class CamaraOverlayWidget extends StatelessWidget {
  const CamaraOverlayWidget({
    Key? key,
    required this.padding,
    required this.aspectRatio,
    required this.color,
  }) : super(key: key);

  final double padding;
  final double aspectRatio;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double parentAspectRatio = constraints.maxWidth / constraints.maxHeight;
      double horizontalPadding;
      double verticalPadding;

      if (parentAspectRatio < aspectRatio) {
        horizontalPadding = padding;
        verticalPadding = (constraints.maxHeight -
                ((constraints.maxWidth - 2 * padding) / aspectRatio)) /
            2;
      } else {
        verticalPadding = padding;
        horizontalPadding = (constraints.maxWidth -
                ((constraints.maxHeight - 2 * padding) * aspectRatio)) /
            2;
      }
      return Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: horizontalPadding,
              color: color,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: horizontalPadding,
              color: color,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(
                left: horizontalPadding,
                right: horizontalPadding,
              ),
              height: verticalPadding,
              color: color,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(
                left: horizontalPadding,
                right: horizontalPadding,
              ),
              height: verticalPadding,
              color: color,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      );
    });
  }
}
