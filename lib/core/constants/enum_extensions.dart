// lib/core/constants/enum_extensions.dart
// Provides .enumName on all enums for Dart version compatibility

extension EnumExtension on Enum {
  String get enumName => toString().split('.').last;
}
