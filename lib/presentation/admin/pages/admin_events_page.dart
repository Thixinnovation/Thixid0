// lib/presentation/admin/pages/admin_events_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../providers/event_provider.dart';
import '../../../services/event_service.dart';
import '../../thix_event/admin/admin_events_dashboard.dart';

class AdminEventsPage extends StatelessWidget {
  final String role;
  
  const AdminEventsPage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EventProvider(EventService(Supabase.instance.client)),
      child: const AdminEventsDashboard(),
    );
  }
}
