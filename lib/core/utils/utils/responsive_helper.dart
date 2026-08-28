import 'package:flutter/material.dart';

class ResponsiveHelper {
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
  static Orientation orientation(BuildContext context) => MediaQuery.of(context).orientation;

  static bool isMobile(BuildContext context, [BoxConstraints? constraints]) {
    final double width = constraints?.maxWidth ?? screenWidth(context);
    return width < 950;
  }

  static bool isTablet(BuildContext context, [BoxConstraints? constraints]) {
    final double width = constraints?.maxWidth ?? screenWidth(context);
    return width >= 950 && width < 1200;
  }

  static bool isDesktop(BuildContext context, [BoxConstraints? constraints]) {
    final double width = constraints?.maxWidth ?? screenWidth(context);
    return width >= 1200;
  }

  static double contentMaxWidth(BuildContext context) {
    final double width = screenWidth(context);
    if (width > 1200) return 1200;
    if (width > 900) return 900;
    return width * 0.92;
  }

  static Widget builder({
    required Widget Function(BuildContext context, BoxConstraints constraints, bool isMobile, bool isTablet, bool isDesktop) builder,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final bool mobile = width < 950;
        final bool tablet = width >= 950 && width < 1200;
        final bool desktop = width >= 1200;
        return builder(context, constraints, mobile, tablet, desktop);
      },
    );
  }
}
