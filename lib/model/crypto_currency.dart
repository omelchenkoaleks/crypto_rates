class CryptoCurrency {
  final String symbol;
  String price;
  final String baseCurrencyIconUrl;
  final String quoteCurrencyIconUrl;
  String baseCurrencyPriceInUSD;
  String quoteCurrencyPriceInUSD;

  CryptoCurrency.fromBinanceJson(
      Map<String, dynamic> json,
      this.baseCurrencyIconUrl,
      this.quoteCurrencyIconUrl,
      this.baseCurrencyPriceInUSD,
      this.quoteCurrencyPriceInUSD)
      : symbol = json['symbol'],
        price = json['price'];

  CryptoCurrency copyWith({
    String? symbol,
    String? price,
    String? baseCurrencyIconUrl,
    String? quoteCurrencyIconUrl,
    String? baseCurrencyPriceInUSD,
    String? quoteCurrencyPriceInUSD,
  }) {
    return CryptoCurrency.fromBinanceJson(
      {
        'symbol': symbol ?? this.symbol,
        'price': price ?? this.price,
      },
      baseCurrencyIconUrl ?? this.baseCurrencyIconUrl,
      quoteCurrencyIconUrl ?? this.quoteCurrencyIconUrl,
      baseCurrencyPriceInUSD ?? this.baseCurrencyPriceInUSD,
      quoteCurrencyPriceInUSD ?? this.quoteCurrencyPriceInUSD,
    );
  }
}
