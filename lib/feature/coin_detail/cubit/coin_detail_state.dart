import 'package:crypto_rates/feature/coin_detail/model/coin_detail.dart';
import 'package:crypto_rates/feature/coin_detail/model/exchange_rate.dart';

class CoinDetailState {
  final CoinDetail coinDetail;
  final bool isLoading;
  final String error;
  final List<ExchangeRate> exchangeRates;
  final bool hasReachedMax;
  final int currentPage;

  CoinDetailState({
    required this.coinDetail,
    required this.isLoading,
    required this.error,
    required this.exchangeRates,
    required this.hasReachedMax,
    required this.currentPage,
  });

  CoinDetailState.initial()
      : coinDetail = CoinDetail.empty(),
        isLoading = false,
        error = '',
        exchangeRates = [],
        hasReachedMax = false,
        currentPage = 1;

  CoinDetailState copyWith({
    CoinDetail? coinDetail,
    bool? isLoading,
    String? error,
    List<ExchangeRate>? exchangeRates,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return CoinDetailState(
      coinDetail: coinDetail ?? this.coinDetail,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      exchangeRates: exchangeRates ?? this.exchangeRates,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
