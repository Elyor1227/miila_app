class PrivacySettings {
  final bool anonymousMode;
  final bool shareAnalytics;

  const PrivacySettings({this.anonymousMode = false, this.shareAnalytics = false});

  factory PrivacySettings.fromJson(Map<String, dynamic>? json) => PrivacySettings(
        anonymousMode: json?['anonymousMode'] == true,
        shareAnalytics: json?['shareAnalytics'] == true,
      );
}

class NotificationSettings {
  final bool periodStart;
  final bool ovulation;
  final bool fertileWindow;
  final bool medicine;
  final bool water;
  final bool dailySymptom;
  final bool newLessons;
  final bool dailyTip;

  const NotificationSettings({
    this.periodStart = true,
    this.ovulation = true,
    this.fertileWindow = false,
    this.medicine = false,
    this.water = true,
    this.dailySymptom = false,
    this.newLessons = true,
    this.dailyTip = true,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic>? json) => NotificationSettings(
        periodStart: json?['periodStart'] != false,
        ovulation: json?['ovulation'] != false,
        fertileWindow: json?['fertileWindow'] == true,
        medicine: json?['medicine'] == true,
        water: json?['water'] != false,
        dailySymptom: json?['dailySymptom'] == true,
        newLessons: json?['newLessons'] != false,
        dailyTip: json?['dailyTip'] != false,
      );

  Map<String, bool> toJson() => {
        'periodStart': periodStart,
        'ovulation': ovulation,
        'fertileWindow': fertileWindow,
        'medicine': medicine,
        'water': water,
        'dailySymptom': dailySymptom,
        'newLessons': newLessons,
        'dailyTip': dailyTip,
      };
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final bool isPro;
  final DateTime? proExpiresAt;
  final DateTime? birthDate;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final DateTime? passwordChangedAt;
  final bool pinEnabled;
  final bool biometricEnabled;
  final int autoLockMinutes;
  final PrivacySettings privacySettings;
  final NotificationSettings notificationSettings;
  final bool subscriptionCancelled;

  const AppUser({
    this.id = '',
    this.name = '',
    this.email = '',
    this.phone = '',
    this.isPro = false,
    this.proExpiresAt,
    this.birthDate,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.passwordChangedAt,
    this.pinEnabled = false,
    this.biometricEnabled = false,
    this.autoLockMinutes = 1,
    this.privacySettings = const PrivacySettings(),
    this.notificationSettings = const NotificationSettings(),
    this.subscriptionCancelled = false,
  });

  String get initial => name.isNotEmpty
      ? name[0].toUpperCase()
      : (email.isNotEmpty ? email[0].toUpperCase() : '?');

  static DateTime? _date(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        isPro: json['isPro'] == true,
        proExpiresAt: _date(json['proExpiresAt']),
        birthDate: _date(json['birthDate']),
        isEmailVerified: json['isEmailVerified'] == true,
        isPhoneVerified: json['isPhoneVerified'] == true,
        passwordChangedAt: _date(json['passwordChangedAt']),
        pinEnabled: json['pinEnabled'] == true,
        biometricEnabled: json['biometricEnabled'] == true,
        autoLockMinutes: (json['autoLockMinutes'] as num?)?.toInt() ?? 1,
        privacySettings: PrivacySettings.fromJson(json['privacySettings'] as Map<String, dynamic>?),
        notificationSettings:
            NotificationSettings.fromJson(json['notificationSettings'] as Map<String, dynamic>?),
        subscriptionCancelled: json['subscriptionCancelled'] == true,
      );
}
