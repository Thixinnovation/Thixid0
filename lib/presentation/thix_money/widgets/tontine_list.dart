// lib/presentation/thix_money/widgets/tontine_list.dart
import 'package:flutter/material.dart';
import 'package:thix_id/models/tontine.dart';
import 'package:thix_id/presentation/thix_money/widgets/tontine_item.dart';

class TontineList extends StatelessWidget {
  final List<Tontine>? tontines;
  final void Function(String id)? onTontineTap;

  const TontineList({
    super.key,
    this.tontines,
    this.onTontineTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayTontines = tontines ?? mockTontines;
    
    return Column(
      children: displayTontines.map((tontine) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TontineItem(
            tontine: tontine,
            onTap: () => onTontineTap?.call(tontine.id),
          ),
        );
      }).toList(),
    );
  }
}
