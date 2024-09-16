import 'package:crypto_rates/feature/coin_detail/cubit/coin_detail_cubit.dart';
import 'package:crypto_rates/feature/coin_detail/cubit/coin_detail_state.dart';
import 'package:crypto_rates/feature/coin_detail/model/coin_detail.dart';
import 'package:crypto_rates/utility/formatting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoinDetailScreen extends StatefulWidget {
  final CoinDetail coinDetail;
  final Set<String> allSymbols;

  const CoinDetailScreen({
    super.key,
    required this.coinDetail,
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
        .fetchExchangeRates(widget.coinDetail.symbol, widget.allSymbols);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !context.read<CoinDetailCubit>().state.isLoading) {
      context.read<CoinDetailCubit>().fetchExchangeRates(
          widget.coinDetail.symbol, widget.allSymbols,
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
        title: Text('Coin Details - ${widget.coinDetail.symbol}'),
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  Column(
                    children: [
                      widget.coinDetail.logoUrl.isNotEmpty
                          ? Image.network(
                              widget.coinDetail.logoUrl,
                              width: 100,
                              height: 100,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 100,
                                  height: 100,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    Formatting.formatSymbol(
                                        widget.coinDetail.symbol),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              width: 100,
                              height: 100,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                Formatting.formatSymbol(
                                        widget.coinDetail.symbol)
                                    .split(' ')[0],
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                      const SizedBox(height: 8),
                      Text(
                        widget.coinDetail.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
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
                                '1 ${widget.coinDetail.symbol} = ${exchangeRate.rate} ${exchangeRate.symbol}'),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
