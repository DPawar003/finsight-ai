import 'package:flutter/material.dart';

enum DeviceType { mobile, tablet, desktop }

class Responsive {
  Responsive._();

  static const double mobileMax = 600;
  static const double tabletMax = 1024;

  static DeviceType deviceTypeOf(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileMax) return DeviceType.mobile;
    if (width < tabletMax) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  static bool isMobile(BuildContext context) => deviceTypeOf(context) == DeviceType.mobile;
  static bool isTablet(BuildContext context) => deviceTypeOf(context) == DeviceType.tablet;
  static bool isDesktop(BuildContext context) => deviceTypeOf(context) == DeviceType.desktop;
}