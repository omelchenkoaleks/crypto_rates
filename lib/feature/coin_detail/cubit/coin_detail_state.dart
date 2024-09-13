import 'package:crypto_rates/feature/coin_detail/model/coin_detail.dart';
import 'package:crypto_rates/feature/coin_detail/model/exchange_rate.dart';

class CoinDetailState {
  final CoinDetail coinDetail;
  final bool isLoading;
  final String error;
  final List<ExchangeRate> exchangeRates;

  CoinDetailState({
    required this.coinDetail,
    required this.isLoading,
    required this.error,
    required this.exchangeRates,
  });

  CoinDetailState.initial()
      : coinDetail = CoinDetail.empty(),
        isLoading = false,
        error = '',
        exchangeRates = [];

  CoinDetailState copyWith({
    CoinDetail? coinDetail,
    bool? isLoading,
    String? error,
    List<ExchangeRate>? exchangeRates,
  }) {
    return CoinDetailState(
      coinDetail: coinDetail ?? this.coinDetail,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      exchangeRates: exchangeRates ?? this.exchangeRates,
    );
  }
}
