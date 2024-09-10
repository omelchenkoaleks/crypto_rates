import 'package:crypto_rates/model/crypto_currency.dart';

class CryptoListState {
  final bool isLoading;
  final bool isRefreshing;
  final List<CryptoCurrency> cryptoList;
  final List<CryptoCurrency> filteredCryptoList;
  final int currentPage;
  final String searchQuery;

  CryptoListState({
    required this.isLoading,
    required this.isRefreshing,
    required this.cryptoList,
    required this.filteredCryptoList,
    required this.currentPage,
    required this.searchQuery,
  });

  CryptoListState.initial()
      : isLoading = false,
        isRefreshing = false,
        cryptoList = [],
        filteredCryptoList = [],
        currentPage = 0,
        searchQuery = '';

  CryptoListState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    List<CryptoCurrency>? cryptoList,
    List<CryptoCurrency>? filteredCryptoList,
    int? currentPage,
    String? searchQuery,
  }) {
    return CryptoListState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      cryptoList: cryptoList ?? this.cryptoList,
      filteredCryptoList: filteredCryptoList ?? this.filteredCryptoList,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
