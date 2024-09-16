class CoinDetail {
  final String symbol;
  final String logoUrl;
  final String fullName;

  CoinDetail({
    required this.symbol,
    required this.logoUrl,
    required this.fullName,
  });

  factory CoinDetail.fromMap(Map<String, dynamic> data) {
    return CoinDetail(
      symbol: data['symbol'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
      fullName: data['fullName'] ?? '',
    );
  }

  factory CoinDetail.empty() {
    return CoinDetail(
      symbol: '',
      logoUrl: '',
      fullName: '',
    );
  }
}
