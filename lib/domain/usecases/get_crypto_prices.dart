import 'package:crypto_rates/domain/entity/crypto_currency.dart';
import 'package:crypto_rates/domain/repository/crypto_currency.dart';

class GetCryptoPrices {
  final CryptoRepository repository;

  GetCryptoPrices(this.repository);

  Future<List<CryptoCurrency>> execute(int page, int perPage) {
    return repository.getCryptoPrices(page, perPage);
  }
}
