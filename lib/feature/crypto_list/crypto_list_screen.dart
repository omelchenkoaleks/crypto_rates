import 'package:crypto_rates/feature/crypto_detail/crypto_detail_screen.dart';
import 'package:crypto_rates/feature/crypto_list/cubit/crypto_list_cubit.dart';
import 'package:crypto_rates/feature/crypto_list/cubit/crypto_list_state.dart';
import 'package:crypto_rates/model/crypto_currency.dart';
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

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !context.read<CryptoListCubit>().state.isLoading) {
        context.read<CryptoListCubit>().fetchCryptoData();
      }
    });
  }

  String formatSymbol(String symbol) {
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

  Future<void> _fetchAndNavigate(
      BuildContext context, CryptoCurrency crypto) async {
    await context.read<CryptoListCubit>().fetchPriceInUSD(
          crypto.baseCurrencyPriceInUSD,
          crypto.quoteCurrencyPriceInUSD,
        );

    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CryptoDetailScreen(crypto: crypto),
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
                  return ListTile(
                    leading: crypto.iconUrl.isNotEmpty
                        ? Image.network(
                            crypto.iconUrl,
                            width: 40,
                            height: 40,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  formatSymbol(crypto.symbol),
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
                              formatSymbol(crypto.symbol).split(' ')[0],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                    title: Text(formatSymbol(crypto.symbol)),
                    subtitle: Text('Price: ${crypto.price}'),
                    onTap: () async {
                      try {
                        await _fetchAndNavigate(context, crypto);
                      } catch (e) {
                        logger.e(
                            'Error on navigate to currency detail screen $e');
                      }
                    },
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

// >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

// class CryptoListScreen extends StatefulWidget {
//   const CryptoListScreen({super.key});

//   @override
//   State<CryptoListScreen> createState() => _CryptoListScreenState();
// }

// class _CryptoListScreenState extends State<CryptoListScreen> {
//   final CurrencyRepository _repository = CurrencyRepository();
//   final List<CryptoCurrency> cryptoList = [];
//   List<CryptoCurrency> filteredCryptoList = [];
//   bool isLoading = false;
//   bool isRefreshing = false;
//   int currentPage = 0;
//   int perPage = 20;
//   final ScrollController scrollController = ScrollController();
//   Timer? refreshTimer;
//   final TextEditingController searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     fetchCryptoData();
//     scrollController.addListener(onScroll);
//     startPeriodicRefresh();
//     searchController.addListener(filterCryptoList);
//   }

//   void onScroll() {
//     if (scrollController.position.pixels ==
//         scrollController.position.maxScrollExtent) {
//       fetchCryptoData();
//     }
//   }

//   Future<void> fetchCryptoData() async {
//     if (isLoading) return;

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       final newItems = await _repository.fetchCryptoData(currentPage, perPage);

//       setState(() {
//         if (newItems.isEmpty) {
//           isLoading = false;
//         } else {
//           cryptoList.addAll(newItems);
//           cryptoList.sort((a, b) => a.symbol.compareTo(b.symbol));
//           currentPage++;
//           filterCryptoList();
//         }
//       });
//     } catch (e) {
//       logger.e("Ошибка загрузки данных: $e");
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> refreshCryptoData() async {
//     setState(() {
//       isRefreshing = true;
//     });

//     try {
//       await _repository.refreshCryptoData(cryptoList);
//       filterCryptoList();
//     } catch (e) {
//       logger.e("Ошибка обновления данных: $e");
//     } finally {
//       setState(() {
//         isRefreshing = false;
//       });
//     }
//   }

//   void startPeriodicRefresh() {
//     refreshTimer = Timer.periodic(const Duration(seconds: 10), (Timer timer) {
//       refreshCryptoData();
//     });
//   }

//   void filterCryptoList() {
//     final query = searchController.text.toLowerCase();

//     setState(() {
//       filteredCryptoList = cryptoList
//           .where((crypto) => crypto.symbol.toLowerCase().contains(query))
//           .toList();
//     });
//   }

//   String formatSymbol(String symbol) {
//     final pattern = RegExp(r'([A-Z]+)([A-Z]{3,4})$');
//     final match = pattern.firstMatch(symbol);

//     if (match != null) {
//       final baseCurrency = match.group(1);
//       final quoteCurrency = match.group(2);
//       return '$baseCurrency $quoteCurrency';
//     }

//     return symbol;
//   }

//   @override
//   void dispose() {
//     scrollController.dispose();
//     refreshTimer?.cancel();
//     searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Crypto Prices'),
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(50.0),
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: searchController,
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 hintText: 'Search...',
//               ),
//               onChanged: (_) => filterCryptoList(),
//             ),
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           filteredCryptoList.isEmpty && !isLoading
//               ? const Center(child: Text('No data available'))
//               : ListView.builder(
//                   controller: scrollController,
//                   itemCount: filteredCryptoList.length + (isLoading ? 1 : 0),
//                   itemBuilder: (context, index) {
//                     if (index == filteredCryptoList.length) {
//                       return Container();
//                     }
//                     final crypto = filteredCryptoList[index];

//                     return ListTile(
//                       leading: crypto.iconUrl.isNotEmpty
//                           ? Image.network(
//                               crypto.iconUrl,
//                               width: 40,
//                               height: 40,
//                               errorBuilder: (context, error, stackTrace) {
//                                 return Container(
//                                   width: 40,
//                                   height: 40,
//                                   alignment: Alignment.center,
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey[300],
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: Text(
//                                     formatSymbol(crypto.symbol),
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 );
//                               },
//                             )
//                           : Container(
//                               width: 40,
//                               height: 40,
//                               alignment: Alignment.center,
//                               decoration: BoxDecoration(
//                                 color: Colors.grey[300],
//                                 shape: BoxShape.circle,
//                               ),
//                               child: Text(
//                                 formatSymbol(crypto.symbol).split(' ')[0],
//                                 style: const TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                       title: Text(formatSymbol(crypto.symbol)),
//                       subtitle: Text('Price: ${crypto.price}'),
//                     );
//                   },
//                 ),
//           if (isLoading || isRefreshing)
//             const Align(
//               alignment: Alignment.center,
//               child: CircularProgressIndicator(),
//             ),
//         ],
//       ),
//     );
//   }
// }
