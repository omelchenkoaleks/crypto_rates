class CryptoCurrency {
  final String symbol;
  String price;
  final String baseCurrencyIconUrl;
  final String quoteCurrencyIconUrl;
  String baseCurrencyPriceInUSD;
  String quoteCurrencyPriceInUSD;
  final String baseCurrencyName;
  final String quoteCurrencyName;

  CryptoCurrency.fromBinanceJson(
    Map<String, dynamic> json,
    this.baseCurrencyIconUrl,
    this.quoteCurrencyIconUrl,
    this.baseCurrencyPriceInUSD,
    this.quoteCurrencyPriceInUSD,
    this.baseCurrencyName,
    this.quoteCurrencyName,
  )   : symbol = json['symbol'],
        price = json['price'];

  CryptoCurrency copyWith({
    String? symbol,
    String? price,
    String? baseCurrencyIconUrl,
    String? quoteCurrencyIconUrl,
    String? baseCurrencyPriceInUSD,
    String? quoteCurrencyPriceInUSD,
    String? baseCurrencyName,
    String? quoteCurrencyName,
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
      baseCurrencyName ?? this.baseCurrencyName,
      quoteCurrencyName ?? this.quoteCurrencyName,
    );
  }
}
