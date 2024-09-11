import 'package:crypto_rates/model/crypto_currency.dart';

class CryptoListState {
  final bool isLoading;
  final bool isRefreshing;
  final List<CryptoCurrency> cryptoList;
  final List<CryptoCurrency> filteredCryptoList;
  final int currentPage;
  final String searchQuery;
  final String baseCurrencyPrice;
  final String quoteCurrencyPrice;

  CryptoListState({
    required this.isLoading,
    required this.isRefreshing,
    required this.cryptoList,
    required this.filteredCryptoList,
    required this.currentPage,
    required this.searchQuery,
    required this.baseCurrencyPrice,
    required this.quoteCurrencyPrice,
  });

  CryptoListState.initial()
      : isLoading = false,
        isRefreshing = false,
        cryptoList = [],
        filteredCryptoList = [],
        currentPage = 0,
        searchQuery = '',
        baseCurrencyPrice = '',
        quoteCurrencyPrice = '';

  CryptoListState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    List<CryptoCurrency>? cryptoList,
    List<CryptoCurrency>? filteredCryptoList,
    int? currentPage,
    String? searchQuery,
    String? baseCurrencyPrice,
    String? quoteCurrencyPrice,
  }) {
    return CryptoListState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      cryptoList: cryptoList ?? this.cryptoList,
      filteredCryptoList: filteredCryptoList ?? this.filteredCryptoList,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      baseCurrencyPrice: baseCurrencyPrice ?? this.baseCurrencyPrice,
      quoteCurrencyPrice: quoteCurrencyPrice ?? this.quoteCurrencyPrice,
    );
  }
}
