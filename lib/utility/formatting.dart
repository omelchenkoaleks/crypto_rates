class Formatting {
  static String formatSymbol(String symbol) {
    if (symbol.endsWith('USDT')) {
      return '${symbol.substring(0, symbol.length - 4)} USDT';
    }

    final pattern = RegExp(r'([A-Z]+)([A-Z]{3})$');
    final match = pattern.firstMatch(symbol);

    if (match != null) {
      final baseCurrency = match.group(1);
      final quoteCurrency = match.group(2);
      return '$baseCurrency $quoteCurrency';
    }

    return symbol;
  }
}
