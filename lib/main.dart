import 'package:crypto_rates/data/repository/crypto_currency_impl.dart';
import 'package:crypto_rates/data/sources/remote_data_source.dart';
import 'package:crypto_rates/domain/usecases/get_crypto_prices.dart';
import 'package:crypto_rates/presentation/cubit/crypto_cubit.dart';
import 'package:crypto_rates/presentation/screen/crypto_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

void main() {
  final remoteDataSource = RemoteDataSource(http.Client());
  final cryptoRepository = CryptoRepositoryImpl(remoteDataSource);
  final getCryptoPrices = GetCryptoPrices(cryptoRepository);

  runApp(MyApp(getCryptoPrices: getCryptoPrices));
}

class MyApp extends StatelessWidget {
  final GetCryptoPrices getCryptoPrices;

  const MyApp({super.key, required this.getCryptoPrices});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (_) => CryptoCubit(getCryptoPrices),
        child: const CryptoListScreen(),
      ),
    );
  }
}




// import 'dart:async';
// import 'dart:convert';

// import 'package:crypto_rates/domain/entity/crypto_currency.dart';
// import 'package:crypto_rates/shared/logger.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class CryptoListScreen extends StatefulWidget {
//   const CryptoListScreen({super.key});

//   @override
//   State<CryptoListScreen> createState() => _CryptoListScreenState();
// }

// class _CryptoListScreenState extends State<CryptoListScreen> {
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

//   Future<void> fetchCryptoData() async {
//     if (isLoading) return;

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       // Получаем цены с Binance
//       final response = await http
//           .get(Uri.parse('https://api.binance.com/api/v3/ticker/price'));

//       if (response.statusCode == 200) {
//         List<dynamic> binanceData = json.decode(response.body);

//         // Получаем иконки с CoinGecko
//         final iconResponse = await http.get(Uri.parse(
//             'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd'));

//         if (iconResponse.statusCode == 200) {
//           List<dynamic> iconData = json.decode(iconResponse.body);

//           setState(() {
//             // Соединяем данные с Binance и CoinGecko
//             List<CryptoCurrency> newItems = binanceData
//                 .skip(currentPage * perPage)
//                 .take(perPage)
//                 .map((binanceJson) {
//               final symbol = binanceJson['symbol'];
//               final baseCurrency =
//                   symbol.split(RegExp(r"[-/]"))[0].toLowerCase();

//               // Ищем иконку для символа в данных CoinGecko
//               final iconUrl = iconData.firstWhere(
//                 (coin) => coin['symbol'] == baseCurrency,
//                 orElse: () => {'image': ''},
//               )['image'];

//               return CryptoCurrency.fromBinanceJson(binanceJson, iconUrl ?? '');
//             }).toList();

//             if (newItems.isEmpty) {
//               isLoading = false;
//             } else {
//               cryptoList.addAll(newItems);
//               cryptoList.sort((a, b) => a.symbol.compareTo(b.symbol));
//               currentPage++;
//               filterCryptoList();
//             }
//           });
//         } else {
//           throw Exception('Failed to load icons');
//         }
//       } else {
//         throw Exception('Failed to load crypto data');
//       }
//     } catch (e) {
//       logger.e("Ошибка загрузки данных: $e");
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   void onScroll() {
//     if (scrollController.position.pixels ==
//         scrollController.position.maxScrollExtent) {
//       fetchCryptoData();
//     }
//   }

//   Future<void> refreshCryptoData() async {
//     setState(() {
//       isRefreshing = true;
//     });

//     try {
//       final response = await http
//           .get(Uri.parse('https://api.binance.com/api/v3/ticker/price'));

//       if (response.statusCode == 200) {
//         List<dynamic> data = json.decode(response.body);

//         setState(() {
//           final newItems = data
//               .map((json) => CryptoCurrency.fromBinanceJson(json, ''))
//               .toList();
//           final Map<String, String> newPrices = {
//             for (var item in newItems) item.symbol: item.price
//           };

//           for (var crypto in cryptoList) {
//             if (newPrices.containsKey(crypto.symbol)) {
//               crypto.price = newPrices[crypto.symbol]!;
//             }
//           }
//           filterCryptoList();
//         });
//       } else {
//         throw Exception('Failed to load crypto data');
//       }
//     } catch (e) {
//       logger.e("Ошибка обновления данных: $e");
//     } finally {
//       setState(() {
//         isRefreshing = false;
//       });
//     }
//   }

//   void startPeriodicRefresh() {
//     refreshTimer = Timer.periodic(const Duration(seconds: 30), (Timer timer) {
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
//                                     crypto.symbol.substring(0, 3).toUpperCase(),
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
//                                 crypto.symbol.substring(0, 3).toUpperCase(),
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                       title: Text(crypto.symbol),
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

// void main() {
//   runApp(const MaterialApp(home: CryptoListScreen()));
// }
