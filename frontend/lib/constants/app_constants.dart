class AppConstants {
  // App Name
  static const String appName = 'VitaFlow';
  static const String appTagline = 'Connecting donors and seekers';

  // Phone number validation
  static const String phoneRegex = r'^[+]?[0-9]{10,13}$';
  static const int phoneLength = 10;

  // OTP validation
  static const int otpLength = 6;

  // Padding and spacing
  static const double paddingXSmall = 8.0;
  static const double paddingSmall = 12.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;

  // Font sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeHeading = 22.0;
  static const double fontSizeTitle = 24.0;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Validation messages
  static const String phoneEmptyError = 'Please enter your phone number';
  static const String phoneInvalidError = 'Please enter a valid phone number';
  static const String otpEmptyError = 'Please enter OTP';
  static const String otpInvalidError = 'OTP must be 6 digits';
}
