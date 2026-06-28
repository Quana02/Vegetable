import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../widgets/network_vegetable_image.dart';
import '../../widgets/price_text.dart';
import '../../widgets/responsive_content.dart';
import '../../widgets/stat_card.dart';

class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({super.key});

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
                  'Xin chào, Hoàng Nam 👋',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Đây là tình hình cửa hàng hôm nay.',
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
                childAspectRatio: count == 1 ? 2.6 : 2.1,
                children: const [
                  StatCard(
                    title: 'Sản phẩm',
                    value: '8',
                    icon: Icons.eco_outlined,
                    color: Colors.green,
                    caption: '+2 tuần này',
                  ),
                  StatCard(
                    title: 'Đơn hôm nay',
                    value: '24',
                    icon: Icons.receipt_long_outlined,
                    color: Colors.blue,
                    caption: '+12% hôm qua',
                  ),
                  StatCard(
                    title: 'Sắp hết hàng',
                    value: '3',
                    icon: Icons.warning_amber_rounded,
                    color: Colors.orange,
                  ),
                  StatCard(
                    title: 'Doanh thu',
                    value: '3,8tr',
                    icon: Icons.payments_outlined,
                    color: Colors.purple,
                    caption: '+8,4% hôm qua',
                  ),
                ],
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 22)),
          SliverToBoxAdapter(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sản phẩm bán chạy',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final vegetable in mockVegetables.take(4)) ...[
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 52,
                            height: 52,
                            child: NetworkVegetableImage(
                              url: vegetable.imageUrl,
                            ),
                          ),
                        ),
                        title: Text(
                          vegetable.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          'Đã bán ${35 - mockVegetables.indexOf(vegetable) * 4} ${vegetable.unit}',
                        ),
                        trailing: PriceText(vegetable.price),
                      ),
                      if (vegetable != mockVegetables.take(4).last)
                        const Divider(height: 1),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}
