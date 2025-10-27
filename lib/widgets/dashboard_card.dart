import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;
  final int? count;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final iconSize = width < 360 ? 44.0 : 52.0;
    final badgeRadius = 14.0;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary.withAlpha(20) : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: iconSize, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              if (count != null)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Semantics(
                    label: '$title count',
                    value: '$count',
                    child: CircleAvatar(
                      radius: badgeRadius,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 1.0),
                        child: Text(
                          '$count',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}