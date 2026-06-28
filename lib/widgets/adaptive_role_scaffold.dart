import 'package:flutter/material.dart';

class RoleDestination {
  const RoleDestination(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class AdaptiveRoleScaffold extends StatelessWidget {
  const AdaptiveRoleScaffold({
    super.key,
    required this.title,
    required this.currentIndex,
    required this.destinations,
    required this.onDestinationSelected,
    required this.body,
    this.actions,
  });

  final String title;
  final int currentIndex;
  final List<RoleDestination> destinations;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 850;
    final appBar = AppBar(
      title: Text(title),
      actions: actions,
      surfaceTintColor: Colors.transparent,
    );

    if (!wide) {
      return Scaffold(
        appBar: appBar,
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: [
            for (final item in destinations)
              NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: item.label,
              ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: MediaQuery.sizeOf(context).width >= 1050,
              selectedIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
              leading: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 28),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.eco_rounded, color: Colors.white),
                ),
              ),
              destinations: [
                for (final item in destinations)
                  NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon),
                    label: Text(item.label),
                  ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                appBar,
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
