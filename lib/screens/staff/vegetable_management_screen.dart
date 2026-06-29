import 'package:flutter/material.dart';

import '../../models/vegetable.dart';
import '../../services/api_client.dart';
import '../../widgets/network_vegetable_image.dart';
import '../../widgets/price_text.dart';
import '../../widgets/responsive_content.dart';

class VegetableManagementScreen extends StatefulWidget {
  const VegetableManagementScreen({super.key});

  @override
  State<VegetableManagementScreen> createState() =>
      _VegetableManagementScreenState();
}

class _VegetableManagementScreenState extends State<VegetableManagementScreen> {
  List<Vegetable> _vegetables = [];
  String _query = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final vegetables = await apiClient.getVegetables(includeInactive: true);
      if (mounted) setState(() => _vegetables = vegetables);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Vegetable> get _filtered => _vegetables
      .where((item) => item.name.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  Future<void> _openForm([Vegetable? vegetable]) async {
    final result = await showDialog<Vegetable>(
      context: context,
      builder: (_) => _VegetableFormDialog(vegetable: vegetable),
    );
    if (result == null) return;
    try {
      final saved = vegetable == null
          ? await apiClient.createVegetable(result)
          : await apiClient.updateVegetable(result);
      if (!mounted) return;
      setState(() {
        final index = _vegetables.indexWhere((item) => item.id == saved.id);
        if (index >= 0) {
          _vegetables[index] = saved;
        } else {
          _vegetables.insert(0, saved);
        }
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _delete(Vegetable vegetable) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa sản phẩm?'),
        content: Text('Bạn có chắc muốn xóa “${vegetable.name}”?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await apiClient.deleteVegetable(vegetable.id);
        if (mounted) {
          setState(
            () => _vegetables.removeWhere((item) => item.id == vegetable.id),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveContent(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: const InputDecoration(
                    hintText: 'Tìm sản phẩm...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add),
                label: Text(
                  MediaQuery.sizeOf(context).width < 520 ? 'Thêm' : 'Thêm rau',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth >= 760) {
                        return _ProductTable(
                          vegetables: _filtered,
                          onEdit: _openForm,
                          onDelete: _delete,
                        );
                      }
                      return ListView.separated(
                        itemCount: _filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = _filtered[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: SizedBox(
                                      width: 68,
                                      height: 68,
                                      child: NetworkVegetableImage(
                                        url: item.imageUrl,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        PriceText(item.price, unit: item.unit),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Kho: ${item.stock}',
                                          style: const TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) => value == 'edit'
                                        ? _openForm(item)
                                        : _delete(item),
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: ListTile(
                                          leading: Icon(Icons.edit_outlined),
                                          title: Text('Sửa'),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: ListTile(
                                          leading: Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                          ),
                                          title: Text('Xóa'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProductTable extends StatelessWidget {
  const _ProductTable({
    required this.vegetables,
    required this.onEdit,
    required this.onDelete,
  });
  final List<Vegetable> vegetables;
  final ValueChanged<Vegetable> onEdit;
  final ValueChanged<Vegetable> onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 24,
          horizontalMargin: 18,
          columns: const [
            DataColumn(label: Text('Sản phẩm')),
            DataColumn(label: Text('Loại')),
            DataColumn(label: Text('Giá')),
            DataColumn(label: Text('Tồn kho')),
            DataColumn(label: Text('Thao tác')),
          ],
          rows: [
            for (final item in vegetables)
              DataRow(
                cells: [
                  DataCell(
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 44,
                            height: 44,
                            child: NetworkVegetableImage(url: item.imageUrl),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            item.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text(item.category)),
                  DataCell(PriceText(item.price)),
                  DataCell(Text('${item.stock}')),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => onEdit(item),
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Sửa',
                        ),
                        IconButton(
                          onPressed: () => onDelete(item),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          tooltip: 'Xóa',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _VegetableFormDialog extends StatefulWidget {
  const _VegetableFormDialog({this.vegetable});
  final Vegetable? vegetable;

  @override
  State<_VegetableFormDialog> createState() => _VegetableFormDialogState();
}

class _VegetableFormDialogState extends State<_VegetableFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(
    text: widget.vegetable?.name,
  );
  late final TextEditingController _category = TextEditingController(
    text: widget.vegetable?.category ?? 'Rau lá',
  );
  late final TextEditingController _price = TextEditingController(
    text: widget.vegetable?.price.round().toString(),
  );
  late final TextEditingController _unit = TextEditingController(
    text: widget.vegetable?.unit ?? 'kg',
  );
  late final TextEditingController _stock = TextEditingController(
    text: widget.vegetable?.stock.toString() ?? '10',
  );
  late final TextEditingController _description = TextEditingController(
    text: widget.vegetable?.description,
  );
  late final TextEditingController _imageUrl = TextEditingController(
    text:
        widget.vegetable?.imageUrl ??
        'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=900',
  );

  @override
  void dispose() {
    for (final controller in [
      _name,
      _category,
      _price,
      _unit,
      _stock,
      _description,
      _imageUrl,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      Vegetable(
        id: widget.vegetable?.id ?? '0',
        name: _name.text.trim(),
        category: _category.text.trim(),
        categoryId: _categoryId(_category.text.trim()),
        price: double.parse(_price.text),
        unit: _unit.text.trim(),
        description: _description.text.trim(),
        imageUrl: _imageUrl.text.trim(),
        stock: int.parse(_stock.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.vegetable == null ? 'Thêm rau mới' : 'Sửa sản phẩm'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Tên rau'),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _category,
                        decoration: const InputDecoration(
                          labelText: 'Loại rau',
                        ),
                        validator: _required,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _unit,
                        decoration: const InputDecoration(labelText: 'Đơn vị'),
                        validator: _required,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _price,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Giá (đ)'),
                        validator: _number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _stock,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Tồn kho'),
                        validator: _number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _imageUrl,
                  decoration: const InputDecoration(labelText: 'URL hình ảnh'),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  minLines: 3,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  validator: _required,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(onPressed: _save, child: const Text('Lưu')),
      ],
    );
  }

  String? _required(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'Không được để trống' : null;
  String? _number(String? value) =>
      double.tryParse(value ?? '') == null ? 'Số chưa hợp lệ' : null;

  int _categoryId(String category) => switch (category.toLowerCase()) {
    'rau củ' => 2,
    'rau quả' => 3,
    'rau hoa' => 4,
    _ => 1,
  };
}
