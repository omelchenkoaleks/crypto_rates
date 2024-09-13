import 'package:crypto_rates/feature/coin_detail/cubit/coin_detail_state.dart';
import 'package:crypto_rates/feature/coin_detail/model/exchange_rate.dart';
import 'package:crypto_rates/repository/coin_repository.dart';
import 'package:crypto_rates/utility/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoinDetailCubit extends Cubit<CoinDetailState> {
  CoinDetailCubit() : super(CoinDetailState.initial());

  final CoinRepository _coinRepository = CoinRepository();
  final int _perPage = 20;

  Future<void> fetchExchangeRates(String baseCurrency, Set<String> allSymbols,
      {bool isNextPage = false}) async {
    if (state.hasReachedMax && isNextPage) {
      return;
    }

    try {
      emit(state.copyWith(isLoading: true));

      final List<Future<ExchangeRate>> futures = [];
      final List<String> symbolsList = allSymbols.toList();

      final start = (state.currentPage - 1) * _perPage;
      final end = start + _perPage;
      final currentSymbols = symbolsList.sublist(
          start, end > symbolsList.length ? symbolsList.length : end);

      for (var symbol in currentSymbols) {
        if (symbol != baseCurrency) {
          futures.add(
            _coinRepository.getExchangeRate(baseCurrency, symbol).then((rate) {
              return ExchangeRate(symbol: symbol, rate: rate);
            }),
          );
        }
      }

      final List<ExchangeRate> newRates = await Future.wait(futures);

      emit(state.copyWith(
        isLoading: false,
        exchangeRates: List.of(state.exchangeRates)..addAll(newRates),
        hasReachedMax: newRates.isEmpty || end >= symbolsList.length,
        currentPage: state.currentPage + 1,
      ));
    } catch (e) {
      logger.e('Error fetching exchange rates: $e');
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
