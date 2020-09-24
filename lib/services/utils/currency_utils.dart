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

  static Future<String> fetchBankingCountry() async {
    final prefs = await Hive.openBox('prefs');
    final country = await prefs.get('banking');
    if (country == null) {
      await prefs.put('banking', 'United States of America');
      return 'United States of America';
    } else {
      return country;
    }
  }

  static Future<void> setPreferredCurrency(String newCountry) async {
    final prefs = await Hive.openBox('prefs');

    await prefs.put('banking', newCountry);
  }
}
