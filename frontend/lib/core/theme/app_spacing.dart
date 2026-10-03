/// Consistent spacing tokens for layouts.
/// Use these instead of hardcoded values.
class AppSpacing {
  AppSpacing._();

  // Base spacing unit
  static const double unit = 4.0;

  // Spacing scale (multiples of unit)
  static const double xs = unit; // 4
  static const double sm = unit * 2; // 8
  static const double md = unit * 3; // 12
  static const double lg = unit * 4; // 16
  static const double xl = unit * 5; // 20
  static const double xxl = unit * 6; // 24
  static const double xxxl = unit * 8; // 32

  // Semantic spacing
  static const double cardPadding = lg; // 16
  static const double screenPadding = lg; // 16
  static const double sectionSpacing = xxl; // 24
  static const double listItemSpacing = md; // 12
  static const double chipSpacing = sm; // 8
  static const double iconSpacing = sm; // 8
  
  // Border radius
  static const double radiusSm = sm; // 8
  static const double radiusMd = md; // 12
  static const double radiusLg = lg; // 16
  static const double radiusXl = xl; // 20
  static const double radiusFull = 999; // Fully rounded
}
