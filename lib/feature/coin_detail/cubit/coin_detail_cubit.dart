import 'package:crypto_rates/feature/coin_detail/cubit/coin_detail_state.dart';
import 'package:crypto_rates/feature/coin_detail/model/exchange_rate.dart';
import 'package:crypto_rates/repository/coin_repository.dart';
import 'package:crypto_rates/utility/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoinDetailCubit extends Cubit<CoinDetailState> {
  CoinDetailCubit() : super(CoinDetailState.initial());

  final CoinRepository _coinRepository = CoinRepository();

  Future<void> fetchExchangeRates(
      String baseCurrency, Set<String> allSymbols) async {
    try {
      emit(state.copyWith(isLoading: true));

      final List<Future<ExchangeRate>> futures = [];

      for (var symbol in allSymbols) {
        if (symbol != baseCurrency) {
          futures.add(
            _coinRepository.getExchangeRate(baseCurrency, symbol).then((rate) {
              return ExchangeRate(symbol: symbol, rate: rate);
            }),
          );
        }
      }

      final List<ExchangeRate> rates = await Future.wait(futures);

      emit(state.copyWith(isLoading: false, exchangeRates: rates));
    } catch (e) {
      logger.e('Error fetching exchange rates: $e');
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
