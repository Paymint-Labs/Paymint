import 'package:hive/hive.dart';

class CurrencyUtilities {
  /// Fetches the preferred currency by user, defaults to USD
  static Future<String> fetchPreferredCurrency() async {
    final prefs = await Hive.openBox('prefs');
    if (prefs.isEmpty) {
      await prefs.put('currency', 'USD');
      return 'USD';
    } else {
      return await prefs.get('currency');
    }
  }
}

