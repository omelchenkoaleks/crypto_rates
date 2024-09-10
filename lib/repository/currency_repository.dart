import 'dart:convert';

import 'package:crypto_rates/model/crypto_currency.dart';
import 'package:http/http.dart' as http;

class CurrencyRepository {
  final http.Client httpClient;

  CurrencyRepository({http.Client? httpClient})
      : httpClient = httpClient ?? http.Client();

  Future<List<CryptoCurrency>> fetchCryptoData(
      int currentPage, int perPage) async {
    final response = await httpClient
        .get(Uri.parse('https://api.binance.com/api/v3/ticker/price'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load crypto data');
    }

    List<dynamic> binanceData = json.decode(response.body);

    final iconResponse = await httpClient.get(Uri.parse(
        'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd'));

    if (iconResponse.statusCode != 200) {
      throw Exception('Failed to load icons');
    }

    List<dynamic> iconData = json.decode(iconResponse.body);

    return binanceData
        .skip(currentPage * perPage)
        .take(perPage)
        .map((binanceJson) {
      final symbol = binanceJson['symbol'];
      final baseCurrency = _extractBaseCurrency(symbol);

      final iconUrl = iconData.firstWhere(
        (coin) => coin['symbol'] == baseCurrency,
        orElse: () => {'image': ''},
      )['image'];

      return CryptoCurrency.fromBinanceJson(binanceJson, iconUrl ?? '');
    }).toList();
  }

  Future<void> refreshCryptoData(List<CryptoCurrency> cryptoList) async {
    final response = await httpClient
        .get(Uri.parse('https://api.binance.com/api/v3/ticker/price'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load crypto data');
    }

    List<dynamic> data = json.decode(response.body);
    final newItems =
        data.map((json) => CryptoCurrency.fromBinanceJson(json, '')).toList();

    final Map<String, String> newPrices = {
      for (var item in newItems) item.symbol: item.price
    };

    for (var crypto in cryptoList) {
      if (newPrices.containsKey(crypto.symbol)) {
        crypto.price = newPrices[crypto.symbol]!;
      }
    }
  }

  String _extractBaseCurrency(String symbol) {
    final pattern = RegExp(r'^([A-Z]{3,5})([A-Z]{3,4})$');
    final match = pattern.firstMatch(symbol);

    if (match != null) {
      return match.group(1)?.toLowerCase() ?? '';
    }

    return '';
  }
}
