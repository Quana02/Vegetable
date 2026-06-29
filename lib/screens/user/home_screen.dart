import 'package:flutter/material.dart';

import '../../models/vegetable.dart';
import '../../services/api_client.dart';
import '../../widgets/responsive_content.dart';
import '../../widgets/vegetable_card.dart';
import 'vegetable_detail_screen.dart';

enum PriceFilter { all, under40, from40to60, over60 }

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onAddToCart,
    required this.onOpenCart,
  });

  final void Function(Vegetable vegetable, int quantity) onAddToCart;
  final VoidCallback onOpenCart;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';
  String _category = 'Tất cả';
  PriceFilter _priceFilter = PriceFilter.all;
  List<Vegetable> _vegetables = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVegetables();
  }

  Future<void> _loadVegetables() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final vegetables = await apiClient.getVegetables();
      if (mounted) setState(() => _vegetables = vegetables);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Vegetable> get _filtered {
    return _vegetables.where((vegetable) {
      final matchText = vegetable.name.toLowerCase().contains(
        _query.toLowerCase(),
      );
      final matchCategory =
          _category == 'Tất cả' || vegetable.category == _category;
      final matchPrice = switch (_priceFilter) {
        PriceFilter.all => true,
        PriceFilter.under40 => vegetable.price < 40000,
        PriceFilter.from40to60 =>
          vegetable.price >= 40000 && vegetable.price <= 60000,
        PriceFilter.over60 => vegetable.price > 60000,
      };
      return matchText && matchCategory && matchPrice;
    }).toList();
  }

  Future<void> _openDetail(Vegetable vegetable) async {
    final buyNow = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => VegetableDetailScreen(
          vegetable: vegetable,
          onAddToCart: widget.onAddToCart,
        ),
      ),
    );
    if (buyNow == true) widget.onOpenCart();
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Tất cả',
      ...{for (final item in _vegetables) item.category},
    ];
    return ResponsiveContent(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tươi ngon mỗi ngày 🌱',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Miễn phí giao hàng cho đơn từ 200.000đ',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .86),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.local_shipping_rounded,
                    color: Colors.white,
                    size: 54,
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 700;
                final search = TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: const InputDecoration(
                    hintText: 'Tìm rau bạn cần...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                );
                final price = DropdownButtonFormField<PriceFilter>(
                  initialValue: _priceFilter,
                  decoration: const InputDecoration(
                    labelText: 'Khoảng giá',
                    prefixIcon: Icon(Icons.tune_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: PriceFilter.all,
                      child: Text('Tất cả mức giá'),
                    ),
                    DropdownMenuItem(
                      value: PriceFilter.under40,
                      child: Text('Dưới 40.000đ'),
                    ),
                    DropdownMenuItem(
                      value: PriceFilter.from40to60,
                      child: Text('40.000đ - 60.000đ'),
                    ),
                    DropdownMenuItem(
                      value: PriceFilter.over60,
                      child: Text('Trên 60.000đ'),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _priceFilter = value ?? PriceFilter.all),
                );
                if (wide) {
                  return Row(
                    children: [
                      Expanded(flex: 2, child: search),
                      const SizedBox(width: 14),
                      Expanded(child: price),
                    ],
                  );
                }
                return Column(
                  children: [search, const SizedBox(height: 12), price],
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final category in categories)
                      Padding(
                        padding: const EdgeInsets.only(right: 9),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: category == _category,
                          onSelected: (_) =>
                              setState(() => _category = category),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '${_filtered.length} sản phẩm',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          if (_loading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _loadVegetables,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            )
          else if (_filtered.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('Không tìm thấy sản phẩm phù hợp.')),
            )
          else
            SliverLayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.crossAxisExtent;
                final count = width >= 1050
                    ? 4
                    : width >= 700
                    ? 3
                    : 2;
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: count,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: width < 430 ? .66 : .76,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final vegetable = _filtered[index];
                    return VegetableCard(
                      vegetable: vegetable,
                      onTap: () => _openDetail(vegetable),
                      onAdd: () => widget.onAddToCart(vegetable, 1),
                    );
                  }, childCount: _filtered.length),
                );
              },
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}
