// lib/presentation/thix_money/widgets/services_grid.dart
import 'package:flutter/material.dart';
import 'package:thix_id/presentation/thix_money/widgets/service_tile.dart';
import 'package:thix_id/models/money_service_model.dart';

class ServicesGrid extends StatelessWidget {
  final void Function(String route)? onServiceTap;
  final int? maxServices;

  const ServicesGrid({
    super.key,
    this.onServiceTap,
    this.maxServices,
  });

  @override
  Widget build(BuildContext context) {
    var services = mockMoneyServices;
    if (maxServices != null) {
      services = services.take(maxServices!).toList();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return ServiceTile(
          service: service,
          onTap: () => onServiceTap?.call(service.route),
        );
      },
    );
  }
}
