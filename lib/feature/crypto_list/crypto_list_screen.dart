import 'package:crypto_rates/feature/coin_detail/coin_detail_screen.dart';
import 'package:crypto_rates/feature/coin_detail/model/coin_detail.dart';
import 'package:crypto_rates/feature/crypto_list/crypto_pair_detail/crypto_pair_detail_screen.dart';
import 'package:crypto_rates/feature/crypto_list/cubit/crypto_list_cubit.dart';
import 'package:crypto_rates/feature/crypto_list/cubit/crypto_list_state.dart';
import 'package:crypto_rates/feature/crypto_list/model/crypto_currency.dart';
import 'package:crypto_rates/utility/formatting.dart';
import 'package:crypto_rates/utility/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CryptoListScreen extends StatefulWidget {
  const CryptoListScreen({super.key});

  @override
  State<CryptoListScreen> createState() => _CryptoListScreenState();
}

class _CryptoListScreenState extends State<CryptoListScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // context.read<CryptoListCubit>().fetchCryptoData();
    context.read<CryptoListCubit>().fetchAllSymbols();

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !context.read<CryptoListCubit>().state.isLoading) {
        context.read<CryptoListCubit>().fetchCryptoData();
      }
    });
  }

  Future<void> _fetchAndNavigate(
      BuildContext context, CryptoCurrency crypto) async {
    await context.read<CryptoListCubit>().fetchPriceInUSD(
          crypto.baseCurrencyPriceInUSD,
          crypto.quoteCurrencyPriceInUSD,
        );

    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CryptoPairDetailScreen(crypto: crypto),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Prices'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search...',
              ),
              onChanged: (query) {
                context.read<CryptoListCubit>().filterCryptoList(query);
              },
            ),
          ),
        ),
      ),
      body: BlocBuilder<CryptoListCubit, CryptoListState>(
        builder: (context, state) {
          if (state.isLoading && state.cryptoList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.filteredCryptoList.isEmpty && !state.isLoading) {
            return const Center(child: Text('No data available'));
          }

          return Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                itemCount:
                    state.filteredCryptoList.length + (state.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.filteredCryptoList.length) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final crypto = state.filteredCryptoList[index];
                  return InkWell(
                    onTap: () async {
                      try {
                        await _fetchAndNavigate(context, crypto);
                      } catch (e) {
                        logger.e(
                            'Error on navigate to currency detail screen $e');
                      }
                    },
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => CoinDetailScreen(
                                      coinDetail: CoinDetail(
                                        symbol: crypto.baseCurrencyPriceInUSD
                                            .toUpperCase(),
                                        logoUrl: crypto.baseCurrencyIconUrl,
                                        fullName: crypto.baseCurrencyName,
                                      ),
                                      allSymbols: state.allSymbols,
                                    ),
                                  ),
                                );
                              },
                              child: crypto.baseCurrencyIconUrl.isNotEmpty
                                  ? Image.network(
                                      crypto.baseCurrencyIconUrl,
                                      width: 40,
                                      height: 40,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: 40,
                                          height: 40,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            Formatting.formatSymbol(
                                                crypto.symbol),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      width: 40,
                                      height: 40,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        Formatting.formatSymbol(crypto.symbol)
                                            .split(' ')[0],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => CoinDetailScreen(
                                      coinDetail: CoinDetail(
                                        symbol: crypto.quoteCurrencyPriceInUSD
                                            .toUpperCase(),
                                        logoUrl: crypto.quoteCurrencyIconUrl,
                                        fullName: crypto.quoteCurrencyName,
                                      ),
                                      allSymbols: state.allSymbols,
                                    ),
                                  ),
                                );
                              },
                              child: crypto.quoteCurrencyIconUrl.isNotEmpty
                                  ? Image.network(
                                      crypto.quoteCurrencyIconUrl,
                                      width: 40,
                                      height: 40,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: 40,
                                          height: 40,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            Formatting.formatSymbol(
                                                crypto.symbol),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      width: 40,
                                      height: 40,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        Formatting.formatSymbol(crypto.symbol)
                                            .split(' ')[1],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(
                              width: 24,
                            ),
                            Column(
                              children: [
                                Text(Formatting.formatSymbol(crypto.symbol)),
                                Text('Price: ${crypto.price}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (state.isRefreshing)
                const Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                ),
            ],
          );
        },
      ),
    );
  }
}
