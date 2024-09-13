import 'package:crypto_rates/feature/coin_detail/cubit/coin_detail_cubit.dart';
import 'package:crypto_rates/feature/coin_detail/cubit/coin_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoinDetailScreen extends StatefulWidget {
  final String symbol;
  final Set<String> allSymbols;

  const CoinDetailScreen({
    super.key,
    required this.symbol,
    required this.allSymbols,
  });

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<CoinDetailCubit>()
        .fetchExchangeRates(widget.symbol, widget.allSymbols);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coin Details - ${widget.symbol}'),
      ),
      body: BlocBuilder<CoinDetailCubit, CoinDetailState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.error.isNotEmpty) {
            return Center(child: Text('Error: ${state.error}'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: state.exchangeRates.length,
                itemBuilder: (context, index) {
                  final exchangeRate = state.exchangeRates[index];
                  return ListTile(
                    title: Text(exchangeRate.symbol),
                    subtitle: Text(
                        '1 ${widget.symbol} = ${exchangeRate.rate} ${exchangeRate.symbol}'),
                  );
                },
              ),
            );
          }
          // return Padding(
          //   padding: const EdgeInsets.only(
          //     left: 36,
          //     top: 24,
          //     right: 16,
          //     bottom: 16,
          //   ),
          //   child: ListView.builder(
          //     itemCount: widget.allSymbols.length,
          //     itemBuilder: (context, index) {
          //       final symbolsList = widget.allSymbols.toList();
          //       final symbol = symbolsList[index];

          //       return ListTile(
          //         title: Text(symbol),
          //       );
          //     },
          //   ),
          // );
        },
      ),
    );
  }
}
