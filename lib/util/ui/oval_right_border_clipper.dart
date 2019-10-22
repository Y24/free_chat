/**
 * Author: Damodar Lohani
 * profile: https://github.com/lohanidamodar
  */

import 'package:flutter/material.dart';

class OvalRightBorderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, 0)
      ..lineTo(size.width - 40, 0)
      ..quadraticBezierTo(
          size.width, size.height / 4, size.width, size.height / 2)
      ..quadraticBezierTo(size.width, size.height - (size.height / 4),
          size.width - 40, size.height)
      ..lineTo(0, size.height);
    /* ..addRRect(RRect.fromLTRBAndCorners(
        0,
        0,
        size.width,
        size.height,
        topRight: const Radius.circular(14.0),
        bottomRight: Radius.elliptical(size.height / 3, size.width / 2),
      )); */
    //  RRect.fromLTRBR(0, 0, size.width, size.height, Radius.circular(12)));
    /*   path.lineTo(0, 0);
    path.lineTo(size.width-40, 0);
    RoundedRectangleBorder();
    path.quadraticBezierTo(
        size.width, size.height / 4, size.width, size.height/2);
    path.quadraticBezierTo(
        size.width, size.height - (size.height / 4), size.width-40, size.height);
    path.lineTo(0, size.height); */
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
