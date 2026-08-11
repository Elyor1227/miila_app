import 'api_client.dart';

class PaymentRecord {
  final String id;
  final String provider;
  final String planLabel;
  final int amount;
  final String status;
  final DateTime? paidAt;
  final DateTime createdAt;

  const PaymentRecord({
    required this.id,
    required this.provider,
    required this.planLabel,
    required this.amount,
    required this.status,
    this.paidAt,
    required this.createdAt,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) => PaymentRecord(
        id: json['_id']?.toString() ?? '',
        provider: json['provider']?.toString() ?? '',
        planLabel: json['planLabel']?.toString() ?? '',
        amount: (json['amount'] as num?)?.toInt() ?? 0,
        status: json['status']?.toString() ?? '',
        paidAt: json['paidAt'] == null ? null : DateTime.tryParse(json['paidAt'].toString()),
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      );
}

class SubscriptionInfo {
  final bool isPro;
  final DateTime? proExpiresAt;
  final bool cancelled;
  final String? planKey;
  final String? planLabel;
  final int? amount;

  const SubscriptionInfo({
    required this.isPro,
    this.proExpiresAt,
    this.cancelled = false,
    this.planKey,
    this.planLabel,
    this.amount,
  });

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) => SubscriptionInfo(
        isPro: json['isPro'] == true,
        proExpiresAt: json['proExpiresAt'] == null
            ? null
            : DateTime.tryParse(json['proExpiresAt'].toString()),
        cancelled: json['cancelled'] == true,
        planKey: json['planKey']?.toString(),
        planLabel: json['planLabel']?.toString(),
        amount: (json['amount'] as num?)?.toInt(),
      );
}

/// /payments endpointlari (M-16, M-21).
class PaymentService {
  final _api = ApiClient.instance;

  /// To'lov yaratadi va gateway checkout URL qaytaradi.
  Future<String> initiate({required String planKey, required String provider}) async {
    final data = await _api.post('/payments/initiate', body: {
      'planKey': planKey,
      'provider': provider,
    });
    return data['checkoutUrl'] as String;
  }

  Future<List<PaymentRecord>> getHistory() async {
    final data = await _api.get('/payments/history');
    return (data['payments'] as List? ?? [])
        .map((p) => PaymentRecord.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  Future<SubscriptionInfo> getSubscription() async {
    final data = await _api.get('/payments/subscription');
    return SubscriptionInfo.fromJson(data['subscription'] as Map<String, dynamic>);
  }

  Future<void> cancelSubscription() async {
    await _api.patch('/payments/subscription/cancel');
  }
}
