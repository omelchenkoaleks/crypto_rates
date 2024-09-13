import 'dart:convert';

import 'package:http/http.dart' as http;

class CoinRepository {
  Future<double> getExchangeRate(String fromCurrency, String toCurrency) async {
    try {
      final fromResponse = await http.get(
        Uri.parse(
            'https://api.binance.com/api/v3/ticker/price?symbol=${fromCurrency}USDT'),
      );

      final toResponse = await http.get(
        Uri.parse(
            'https://api.binance.com/api/v3/ticker/price?symbol=${toCurrency}USDT'),
      );

      if (fromResponse.statusCode == 200 && toResponse.statusCode == 200) {
        final fromPriceData = jsonDecode(fromResponse.body);
        final toPriceData = jsonDecode(toResponse.body);

        if (fromPriceData.containsKey('price') &&
            toPriceData.containsKey('price')) {
          final fromPrice = double.parse(fromPriceData['price']);
          final toPrice = double.parse(toPriceData['price']);

          if (toPrice == 0) {
            return 0;
          }

          return fromPrice / toPrice;
        } else {
          return 0;
        }
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }
}
