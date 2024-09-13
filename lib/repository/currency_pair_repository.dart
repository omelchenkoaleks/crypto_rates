import 'dart:convert';

import 'package:crypto_rates/feature/crypto_list/model/crypto_currency.dart';
import 'package:http/http.dart' as http;

class CurrencyPairRepository {
  final http.Client httpClient;

  CurrencyPairRepository({http.Client? httpClient})
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
      final quoteCurrency = _extractQuoteCurrency(symbol);

      final baseCurrencyIconUrl = iconData.firstWhere(
        (coin) => coin['symbol'] == baseCurrency,
        orElse: () => {'image': ''},
      )['image'];

      final quoteCurrencyIconUrl = iconData.firstWhere(
        (coin) => coin['symbol'] == quoteCurrency,
        orElse: () => {'image': ''},
      )['image'];

      return CryptoCurrency.fromBinanceJson(
          binanceJson,
          baseCurrencyIconUrl ?? '',
          quoteCurrencyIconUrl ?? '',
          baseCurrency,
          quoteCurrency);
    }).toList();
  }

  Future<void> refreshCryptoData(List<CryptoCurrency> cryptoList) async {
    final response = await httpClient
        .get(Uri.parse('https://api.binance.com/api/v3/ticker/price'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load crypto data');
    }

    List<dynamic> data = json.decode(response.body);

    final List<Future<CryptoCurrency>> newItemsFutures = data.map((json) async {
      final symbol = json['symbol'];

      final baseCurrency = _extractBaseCurrency(symbol);
      final quoteCurrency = _extractQuoteCurrency(symbol);

      final baseCurrencyPriceInUSD = await fetchPriceInUSD(baseCurrency);
      final quoteCurrencyPriceInUSD = await fetchPriceInUSD(quoteCurrency);

      return CryptoCurrency.fromBinanceJson(json, '', '',
          baseCurrencyPriceInUSD ?? '', quoteCurrencyPriceInUSD ?? '');
    }).toList();

    final List<CryptoCurrency> newItems = await Future.wait(newItemsFutures);

    final Map<String, String> newPrices = {
      for (var item in newItems) item.symbol: item.price
    };

    for (var crypto in cryptoList) {
      if (newPrices.containsKey(crypto.symbol)) {
        final newItem =
            newItems.firstWhere((item) => item.symbol == crypto.symbol);

        crypto.price = newItem.price;

        crypto.baseCurrencyPriceInUSD = newItem.baseCurrencyPriceInUSD;

        crypto.quoteCurrencyPriceInUSD = newItem.quoteCurrencyPriceInUSD;
      }
    }
  }

  Future<String?> fetchPriceInUSD(String symbol) async {
    if (symbol.isEmpty || !RegExp(r'^[A-Z0-9]{1,20}$').hasMatch(symbol)) {
      throw Exception('Invalid symbol format: $symbol');
    }

    final url = Uri.parse(
        'https://api.binance.com/api/v3/ticker/price?symbol=${symbol.toUpperCase()}USDT');
    final response = await httpClient.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load price in USD');
    }

    final json = jsonDecode(response.body);
    return json['price'];
  }

  String _extractBaseCurrency(String symbol) {
    if (symbol.endsWith('USDT') ||
        symbol.endsWith('TUSD') ||
        symbol.endsWith('BUSD') ||
        symbol.endsWith('USDC')) {
      return symbol.substring(0, symbol.length - 4).toLowerCase();
    }

    final pattern = RegExp(r'^([A-Z]{3,5})([A-Z]{3,4})$');
    final match = pattern.firstMatch(symbol);

    if (match != null) {
      return match.group(1)?.toLowerCase() ?? '';
    }

    return '';
  }

  String _extractQuoteCurrency(String symbol) {
    if (symbol.endsWith('USDT')) {
      return 'usdt';
    } else if (symbol.endsWith('TUSD')) {
      return 'tusd';
    } else if (symbol.endsWith('BUSD')) {
      return 'busd';
    } else if (symbol.endsWith('USDC')) {
      return 'usdc';
    }

    final pattern = RegExp(r'^([A-Z]{3,5})([A-Z]{3,4})$');
    final match = pattern.firstMatch(symbol);

    if (match != null) {
      return match.group(2)?.toLowerCase() ?? '';
    }

    return '';
  }

  Future<Set<String>> fetchAllSymbols() async {
    final response = await httpClient
        .get(Uri.parse('https://api.binance.com/api/v3/ticker/price'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load crypto data');
    }

    List<dynamic> binanceData = json.decode(response.body);

    Set<String> symbols = {};

    for (var pair in binanceData) {
      final symbol = pair['symbol'];

      final baseCurrency = _extractBaseCurrency(symbol);
      final quoteCurrency = _extractQuoteCurrency(symbol);

      symbols.add(baseCurrency.toUpperCase());
      symbols.add(quoteCurrency.toUpperCase());
    }

    return symbols;
  }
}
