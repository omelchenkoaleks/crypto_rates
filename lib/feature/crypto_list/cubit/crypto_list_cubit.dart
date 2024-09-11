import 'dart:async';

import 'package:crypto_rates/feature/crypto_list/cubit/crypto_list_state.dart';
import 'package:crypto_rates/model/crypto_currency.dart';
import 'package:crypto_rates/repository/currency_repository.dart';
import 'package:crypto_rates/utility/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CryptoListCubit extends Cubit<CryptoListState> {
  CryptoListCubit() : super(CryptoListState.initial()) {
    fetchCryptoData();
    startPeriodicRefresh();
  }

  final CurrencyRepository _repository = CurrencyRepository();
  Timer? _refreshTimer;

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }

  void startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (Timer timer) {
      fetchCryptoData();
    });
  }

  void stopPeriodicRefresh() {
    _refreshTimer?.cancel();
  }

  Future<void> fetchCryptoData() async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true));

    try {
      final newItems = await _repository.fetchCryptoData(state.currentPage, 20);

      if (newItems.isEmpty) {
        emit(state.copyWith(isLoading: false));
      } else {
        final updatedCryptoList = List<CryptoCurrency>.from(state.cryptoList)
          ..addAll(newItems);
        updatedCryptoList.sort((a, b) => a.symbol.compareTo(b.symbol));

        emit(state.copyWith(
          isLoading: false,
          cryptoList: updatedCryptoList,
          filteredCryptoList:
              _filterCryptoList(updatedCryptoList, state.searchQuery),
          currentPage: state.currentPage + 1,
        ));
      }
    } catch (e) {
      logger.e('Error with fetch crypto data: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> refreshCryptoData() async {
    emit(state.copyWith(isRefreshing: true));

    try {
      await _repository.refreshCryptoData(state.cryptoList);
      emit(state.copyWith(
        isRefreshing: false,
        filteredCryptoList:
            _filterCryptoList(state.cryptoList, state.searchQuery),
      ));
    } catch (e) {
      emit(state.copyWith(isRefreshing: false));
    }
  }

  void filterCryptoList(String query) {
    emit(state.copyWith(
      searchQuery: query,
      filteredCryptoList: _filterCryptoList(state.cryptoList, query),
    ));
  }

  List<CryptoCurrency> _filterCryptoList(
      List<CryptoCurrency> list, String query) {
    return list
        .where((crypto) =>
            crypto.symbol.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<void> fetchPriceInUSD(String baseSymbol, String quoteSymbol) async {
    try {
      final baseCurrencyPriceInUSD =
          await _repository.fetchPriceInUSD(baseSymbol.toUpperCase());

      final quoteCurrencyPriceInUSD = quoteSymbol.toUpperCase() == 'USDT'
          ? '1'
          : await _repository.fetchPriceInUSD(quoteSymbol.toUpperCase());

      if (baseCurrencyPriceInUSD != null && quoteCurrencyPriceInUSD != null) {
        logger.i(
            'Fetch base currency price in USDT: $baseCurrencyPriceInUSD | and quote currency price in USDT: $quoteCurrencyPriceInUSD');

        emit(
          state.copyWith(
            baseCurrencyPrice: baseCurrencyPriceInUSD,
            quoteCurrencyPrice: quoteCurrencyPriceInUSD,
          ),
        );
      } else {
        throw Exception('One of the fetched prices is null');
      }
    } catch (e) {
      logger.e(
          'Error fetching price in USD for base symbol $baseSymbol or quote symbol $quoteSymbol: $e');
    }
  }
}
