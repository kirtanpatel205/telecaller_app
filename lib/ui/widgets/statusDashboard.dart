import 'package:flutter/material.dart';
import 'package:telecaller_app/ui/widgets/custom_card.dart';

/// Minimal Stats Dashboard Widget
class StatsDashboard extends StatelessWidget {
  final Map<String, dynamic> stats; // {label: value}
  final Map<String, Color>? colors;

  const StatsDashboard({
    Key? key,
    required this.stats,
    this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _buildStats(),
        ),
      ),
    );
  }

  List<Widget> _buildStats() {
    final entries = stats.entries.toList();
    return List.generate(
      entries.length * 2 - 1,
          (index) {
        if (index.isEven) {
          final statIndex = index ~/ 2;
          final entry = entries[statIndex];
          return Expanded(
            child: _StatColumn(
              label: entry.key,
              value: entry.value.toString(),
              color: colors?[entry.key] ?? Colors.blue,
            ),
          );
        } else {
          return SizedBox(
            height: 40,
            child: VerticalDivider(color: Colors.grey[300]),
          );
        }
      },
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}