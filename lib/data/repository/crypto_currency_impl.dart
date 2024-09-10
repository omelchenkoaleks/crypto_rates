import 'package:crypto_rates/data/sources/remote_data_source.dart';
import 'package:crypto_rates/domain/entity/crypto_currency.dart';
import 'package:crypto_rates/domain/repository/crypto_currency.dart';

class CryptoRepositoryImpl implements CryptoRepository {
  final RemoteDataSource remoteDataSource;

  CryptoRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<CryptoCurrency>> getCryptoPrices(int page, int perPage) async {
    return await remoteDataSource.fetchCryptoData(page, perPage);
  }
}
