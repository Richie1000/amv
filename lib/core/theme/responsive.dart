import 'package:flutter/material.dart';

/// Breakpoints
/// mobile  : < 600
/// tablet  : 600 – 1023
/// desktop : >= 1024
class Responsive {
  Responsive._();

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= 600 && w < 1024;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1024;

  /// True when side nav should be shown (tablet + desktop)
  static bool showSideNav(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 600;
}

/// Wraps a widget and rebuilds when the layout class changes.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;

  @override
  Widget build(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return (desktop ?? tablet ?? mobile)(context);
    }
    if (Responsive.isTablet(context)) {
      return (tablet ?? mobile)(context);
    }
    return mobile(context);
  }
}
