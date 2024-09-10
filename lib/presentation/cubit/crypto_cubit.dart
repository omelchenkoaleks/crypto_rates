import 'package:crypto_rates/domain/entity/crypto_currency.dart';
import 'package:crypto_rates/domain/usecases/get_crypto_prices.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CryptoCubit extends Cubit<List<CryptoCurrency>> {
  final GetCryptoPrices getCryptoPrices;
  int currentPage = 0;
  int perPage = 20;

  CryptoCubit(this.getCryptoPrices) : super([]);

  void loadCryptoData() async {
    final newCryptoList = await getCryptoPrices.execute(currentPage, perPage);
    currentPage++;
    emit([...state, ...newCryptoList]);
  }
}
