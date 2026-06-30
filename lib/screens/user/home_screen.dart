import 'package:flutter/material.dart';

import '../../models/vegetable.dart';
import '../../services/api_client.dart';
import '../../widgets/responsive_content.dart';
import '../../widgets/vegetable_card.dart';
import 'vegetable_detail_screen.dart';

enum PriceFilter { all, under40, from40to60, over60 }

enum SortOption { none, priceAsc, priceDesc, nameAsc }

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
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  String _query = '';
  String _category = 'Tất cả';
  PriceFilter _priceFilter = PriceFilter.all;
  SortOption _sortOption = SortOption.none;
  List<Vegetable> _vegetables = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVegetables();
    apiClient.realtimeUpdateNotifier.addListener(_loadVegetables);
    apiClient.startRealtimeConnection();
  }

  @override
  void dispose() {
    apiClient.realtimeUpdateNotifier.removeListener(_loadVegetables);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadVegetables() async {
    // Hiển thị danh sách rau: Lấy dữ liệu từ API để hiển thị lên giao diện.
    // Hoạt động: Gọi hàm getVegetables từ apiClient và cập nhật lại state _vegetables.
    // Chuyển dữ liệu: Dữ liệu từ API được đổ vào biến _vegetables để widget build lại danh sách.
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
    // Filter, search rau: Lọc và sắp xếp danh sách rau.
    // Hoạt động: Lọc theo tên, danh mục, giá.
    // Chuyển dữ liệu: Trả về List<Vegetable> đã được lọc.
    final filtered = _vegetables.where((vegetable) {
      final queryLower = _query.toLowerCase();
      final nameLower = vegetable.name.toLowerCase();

      final matchText = nameLower.contains(queryLower);

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

    // Sắp xếp: Ưu tiên theo lựa chọn người dùng, mặc định là mới nhất lên đầu.
    filtered.sort((a, b) {
      if (_sortOption == SortOption.none) {
        final aDate = a.createdAt ?? DateTime(2000);
        final bDate = b.createdAt ?? DateTime(2000);
        return bDate.compareTo(aDate); // Mới nhất lên đầu
      }

      switch (_sortOption) {
        case SortOption.priceAsc:
          return a.price.compareTo(b.price);
        case SortOption.priceDesc:
          return b.price.compareTo(a.price);
        case SortOption.nameAsc:
          return a.name.compareTo(b.name);
        default:
          return 0;
      }
    });

    return filtered;
  }


  Future<void> _openDetail(Vegetable vegetable) async {
    // Chi tiết sản phẩm: Điều hướng người dùng đến màn hình xem chi tiết một loại rau.
    // Hoạt động: Sử dụng Navigator.push để chuyển sang VegetableDetailScreen.
    // Chuyển dữ liệu: Chuyển đối tượng vegetable và hàm onAddToCart sang màn hình chi tiết.
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

  Widget _buildSortDropdown() {
    return DropdownButtonFormField<SortOption>(
      initialValue: _sortOption,
      isExpanded: true, // Chống tràn viền
      decoration: const InputDecoration(
        labelText: 'Sắp xếp',
        prefixIcon: Icon(Icons.sort_rounded),
        contentPadding: EdgeInsets.symmetric(horizontal: 8),
      ),
      items: const [
        DropdownMenuItem(value: SortOption.none, child: Text('Mặc định')),
        DropdownMenuItem(value: SortOption.priceAsc, child: Text('Giá thấp đến cao')),
        DropdownMenuItem(value: SortOption.priceDesc, child: Text('Giá cao đến thấp')),
        DropdownMenuItem(value: SortOption.nameAsc, child: Text('Tên A-Z')),
      ],
      onChanged: (value) => setState(() => _sortOption = value ?? SortOption.none),
    );
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
                          'Tươi ngon mỗi ngày ',
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
                // Search rau: Ô nhập văn bản để tìm kiếm rau theo tên.
                // Cách hoạt động: Khi nhập, _query sẽ được cập nhật và trigger rebuild để lọc danh sách.
                // Chuyển dữ liệu: _query được dùng trong getter _filtered để so khớp với vegetable.name.
                final search = TextField(
                  key: const ValueKey('home_search_field'),
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onTap: () => _searchFocusNode.requestFocus(),
                  onChanged: (value) => setState(() => _query = value),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.search,
                  enableIMEPersonalizedLearning: true,
                  decoration: InputDecoration(
                    hintText: 'Tìm rau bạn cần...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                              _searchFocusNode.unfocus();
                            },
                          )
                        : null,
                  ),
                );
                // Filter rau theo giá: Dropdown để chọn khoảng giá.
                // Cách hoạt động: Khi chọn, _priceFilter được cập nhật và trigger rebuild.
                // Chuyển dữ liệu: _priceFilter được dùng trong getter _filtered để lọc sản phẩm theo đơn giá.
                final price = DropdownButtonFormField<PriceFilter>(
                  initialValue: _priceFilter,
                  isExpanded: true, // Chống tràn viền bằng cách bắt nội dung nằm gọn trong ô
                  decoration: const InputDecoration(
                    labelText: 'Khoảng giá',
                    prefixIcon: Icon(Icons.tune_rounded),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
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
                      const SizedBox(width: 14),
                      Expanded(child: _buildSortDropdown()),
                    ],
                  );
                }
                return Column(
                  children: [
                    search,
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: price),
                        const SizedBox(width: 12),
                        Expanded(child: _buildSortDropdown()),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Row(
                children: [
                  Expanded(
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
                  if (_query.isNotEmpty || _category != 'Tất cả' || _priceFilter != PriceFilter.all)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _query = '';
                          _category = 'Tất cả';
                          _priceFilter = PriceFilter.all;
                          _sortOption = SortOption.none;
                          _searchController.clear();
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Xóa lọc'),
                    ),
                ],
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
