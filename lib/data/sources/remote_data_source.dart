import 'dart:convert';

import 'package:crypto_rates/domain/entity/crypto_currency.dart';
import 'package:crypto_rates/shared/logger.dart';
import 'package:http/http.dart' as http;

class RemoteDataSource {
  final http.Client client;

  RemoteDataSource(this.client);

  Future<List<CryptoCurrency>> fetchCryptoData(int page, int perPage) async {
    try {
      final response = await client
          .get(Uri.parse('https://api.binance.com/api/v3/ticker/price'));

      if (response.statusCode == 200) {
        final binanceData = json.decode(response.body) as List<dynamic>;

        // Fetching icons from CoinGecko
        final iconResponse = await client.get(Uri.parse(
            'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd'));
        if (iconResponse.statusCode == 200) {
          final iconData = json.decode(iconResponse.body) as List<dynamic>;

          final List<CryptoCurrency> cryptoList =
              binanceData.skip(page * perPage).take(perPage).map((binanceJson) {
            final symbol = binanceJson['symbol'];
            final baseCurrency = symbol.split(RegExp(r"[-/]"))[0].toLowerCase();

            final iconUrl = iconData.firstWhere(
              (coin) => coin['symbol'] == baseCurrency,
              orElse: () => {'image': ''},
            )['image'];

            return CryptoCurrency.fromBinanceJson(binanceJson, iconUrl ?? '');
          }).toList();

          return cryptoList;
        } else {
          throw Exception('Failed to load icons');
        }
      } else {
        throw Exception('Failed to load crypto data');
      }
    } catch (e) {
      logger.e("Error fetching crypto data: $e");
      rethrow;
    }
  }
}
