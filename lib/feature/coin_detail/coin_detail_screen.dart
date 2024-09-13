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
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    context
        .read<CoinDetailCubit>()
        .fetchExchangeRates(widget.symbol, widget.allSymbols);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !context.read<CoinDetailCubit>().state.isLoading) {
      context.read<CoinDetailCubit>().fetchExchangeRates(
          widget.symbol, widget.allSymbols,
          isNextPage: true);
    }
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
        title: Text('Coin Details - ${widget.symbol}'),
      ),
      body: BlocBuilder<CoinDetailCubit, CoinDetailState>(
        builder: (context, state) {
          if (state.isLoading && state.exchangeRates.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.error.isNotEmpty) {
            return Center(child: Text('Error: ${state.error}'));
          } else {
            final filteredRates = state.exchangeRates
                .where((exchangeRate) => exchangeRate.rate != 0)
                .toList();

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: state.hasReachedMax
                    ? filteredRates.length
                    : filteredRates.length + 1,
                itemBuilder: (context, index) {
                  if (index >= filteredRates.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else {
                    final exchangeRate = filteredRates[index];
                    return ListTile(
                      title: Text(exchangeRate.symbol),
                      subtitle: Text(
                          '1 ${widget.symbol} = ${exchangeRate.rate} ${exchangeRate.symbol}'),
                    );
                  }
                },
              ),
            );
          }
        },
      ),
    );
  }
}
