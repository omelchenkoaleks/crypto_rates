import 'package:crypto_rates/domain/entity/crypto_currency.dart';

abstract class CryptoRepository {
  Future<List<CryptoCurrency>> getCryptoPrices(int page, int perPage);
}
