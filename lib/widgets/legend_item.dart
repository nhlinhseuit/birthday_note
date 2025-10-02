import 'package:flutter/cupertino.dart';

class LegendItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final double iconSize;

  const LegendItem({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    this.iconSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: iconSize,
          color: color,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: CupertinoColors.label,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
