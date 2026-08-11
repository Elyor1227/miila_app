import '../models/tip.dart';
import 'api_client.dart';

/// /tips endpointlari — kunlik tibbiy maslahat.
class TipsService {
  final _api = ApiClient.instance;

  Future<DailyTip?> getToday() async {
    final data = await _api.get('/tips/today');
    final tip = data['tip'];
    if (tip == null) return null;
    return DailyTip.fromJson(tip as Map<String, dynamic>);
  }
}
