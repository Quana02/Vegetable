import 'package:flutter/material.dart';

import '../../widgets/responsive_content.dart';
import '../../widgets/stat_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveContent(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chào buổi sáng, Quốc Bảo 👋',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Theo dõi hoạt động tổng quan của Green Basket.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          SliverLayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.crossAxisExtent >= 1000
                  ? 4
                  : constraints.crossAxisExtent >= 600
                  ? 2
                  : 1;
              return SliverGrid.count(
                crossAxisCount: count,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: count == 1 ? 2.7 : 2.05,
                children: const [
                  StatCard(
                    title: 'Tổng tài khoản',
                    value: '1.248',
                    icon: Icons.group_outlined,
                    color: Colors.blue,
                    caption: '+32 tháng này',
                  ),
                  StatCard(
                    title: 'Nhân viên',
                    value: '18',
                    icon: Icons.badge_outlined,
                    color: Colors.orange,
                    caption: '16 đang hoạt động',
                  ),
                  StatCard(
                    title: 'Sản phẩm',
                    value: '86',
                    icon: Icons.inventory_2_outlined,
                    color: Colors.green,
                    caption: '72 còn hàng',
                  ),
                  StatCard(
                    title: 'Doanh thu tháng',
                    value: '128tr',
                    icon: Icons.trending_up_rounded,
                    color: Colors.purple,
                    caption: '+14,2% tháng trước',
                  ),
                ],
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 22)),
          SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final activity = _ActivityCard();
                final roles = _RoleOverview();
                if (constraints.maxWidth >= 760) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: activity),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: roles),
                    ],
                  );
                }
                return Column(
                  children: [activity, const SizedBox(height: 16), roles],
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const activities = [
      (
        Icons.person_add_alt,
        Colors.blue,
        'Tài khoản mới được tạo',
        'Nguyễn Hải Yến · 5 phút trước',
      ),
      (
        Icons.edit_outlined,
        Colors.orange,
        'Sản phẩm đã được cập nhật',
        'Cải bó xôi · 22 phút trước',
      ),
      (
        Icons.receipt_long_outlined,
        Colors.green,
        'Đơn hàng #GB1024 hoàn tất',
        'Giá trị 428.000đ · 1 giờ trước',
      ),
      (
        Icons.badge_outlined,
        Colors.purple,
        'Thay đổi vai trò tài khoản',
        'Trần Văn Đức → Nhân viên · 2 giờ trước',
      ),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hoạt động gần đây',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            for (final item in activities)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: item.$2.withValues(alpha: .12),
                  child: Icon(item.$1, color: item.$2, size: 20),
                ),
                title: Text(
                  item.$3,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(item.$4),
              ),
          ],
        ),
      ),
    );
  }
}

class _RoleOverview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phân bố vai trò',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 24),
            const _RoleBar(
              label: 'Người dùng',
              value: 0.78,
              count: '1.212',
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            const _RoleBar(
              label: 'Nhân viên',
              value: 0.15,
              count: '18',
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            const _RoleBar(
              label: 'Quản trị viên',
              value: 0.07,
              count: '8',
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleBar extends StatelessWidget {
  const _RoleBar({
    required this.label,
    required this.value,
    required this.count,
    required this.color,
  });
  final String label;
  final double value;
  final String count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            const Spacer(),
            Text(count, style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 9,
            color: color,
            backgroundColor: color.withValues(alpha: .12),
          ),
        ),
      ],
    );
  }
}
