import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'colors.dart';

enum CpIconButtonVariant {
  dark,
  grey,
  light,
  black,
  transparent,
}

enum CpIconButtonSize {
  big,
  normal,
  small,
  micro,
}

class CpIconButton extends StatelessWidget {
  const CpIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.variant = CpIconButtonVariant.grey,
    this.size = CpIconButtonSize.normal,
  }) : super(key: key);

  final SvgPicture icon;
  final VoidCallback onPressed;
  final CpIconButtonVariant variant;
  final CpIconButtonSize size;

  Color get _backgroundColor {
    switch (variant) {
      case CpIconButtonVariant.dark:
        return CpColors.yellowColor;
      case CpIconButtonVariant.grey:
        return CpColors.greyIconBackgroundColor;
      case CpIconButtonVariant.light:
        return Colors.white;
      case CpIconButtonVariant.black:
        return CpColors.darkBackground;
      case CpIconButtonVariant.transparent:
        return Colors.transparent;
    }
  }

  double get _size {
    switch (size) {
      case CpIconButtonSize.big:
        return 40;
      case CpIconButtonSize.normal:
        return 34;
      case CpIconButtonSize.small:
        return 28;
      case CpIconButtonSize.micro:
        return 22;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        width: _size,
        decoration: ShapeDecoration(
          shape: const CircleBorder(),
          color: _backgroundColor,
        ),
        child: IconButton(
          padding: const EdgeInsets.all(6),
          icon: icon,
          onPressed: onPressed,
        ),
      );
}
