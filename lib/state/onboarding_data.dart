/// Onboarding jarayonida yig'ilgan ma'lumotlarni vaqtincha saqlaydi:
/// R-06 dagi hisob ma'lumotlari (OTP tasdiqlangach register'ga yuboriladi)
/// va R-08..R-10 sikl parametrlari (R-13 da /tracker/cycles'ga yuboriladi).
class OnboardingData {
  OnboardingData._();
  static final OnboardingData instance = OnboardingData._();

  // R-06 — hisob (SMS tasdiqlashdan keyin register qilinadi)
  String name = '';
  String email = '';
  String phone = '';
  String password = '';

  // R-08..R-10 — sikl
  int age = 22;
  DateTime lastPeriodDate = DateTime.now();
  int cycleLength = 28;
  int periodLength = 5;

  void reset() {
    name = '';
    email = '';
    phone = '';
    password = '';
    age = 22;
    lastPeriodDate = DateTime.now();
    cycleLength = 28;
    periodLength = 5;
  }
}
