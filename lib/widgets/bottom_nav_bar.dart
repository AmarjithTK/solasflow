import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';


/// Navigation destination data.
class NavDestination {
  final IconData icon;
  final String label;

  const NavDestination({
    required this.icon,
    required this.label,
  });
}

/// Custom bottom navigation bar.
class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavDestination> destinations;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colors = brightness == Brightness.light
        ? AppColors.light
        : AppColors.dark;

    return Container(
      color: colors.navBackground,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(destinations.length, (index) {
              final dest = destinations[index];
              final selected = index == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onDestinationSelected(index),
                  child: _NavTab(
                    destination: dest,
                    selected: selected,
                    colors: colors,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final NavDestination destination;
  final bool selected;
  final ColorTokens colors;

  const _NavTab({
    required this.destination,
    required this.selected,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = colors.navActive;
    final inactiveColor = colors.navInactive;

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: selected ? 1.0 : 0.85,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: Icon(
              destination.icon,
              size: 22,
              color: selected ? activeColor : inactiveColor,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                destination.label,
                maxLines: 1,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? activeColor : inactiveColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
