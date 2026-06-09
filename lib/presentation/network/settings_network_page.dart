import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsNetworkPage extends StatefulWidget {
  const SettingsNetworkPage({super.key});

  @override
  State<SettingsNetworkPage> createState() => _SettingsNetworkPageState();
}

class _SettingsNetworkPageState extends State<SettingsNetworkPage> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _messageNotifications = true;
  String _privacyLevel = 'public';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final response = await supabase.from('profiles').select('notification_settings, privacy_settings').eq('id', userId).single();
        final settings = response['notification_settings'] as Map<String, dynamic>?;
        if (settings != null) {
          setState(() {
            _pushNotifications = settings['push'] ?? true;
            _emailNotifications = settings['email'] ?? true;
            _messageNotifications = settings['messages'] ?? true;
          });
        }
        final privacy = response['privacy_settings'] as Map<String, dynamic>?;
        if (privacy != null) setState(() => _privacyLevel = privacy['profile_visibility'] ?? 'public');
      }
    } catch (e) {
      print('Error loading settings: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveSettings() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        await supabase.from('profiles').update({
          'notification_settings': {'push': _pushNotifications, 'email': _emailNotifications, 'messages': _messageNotifications},
          'privacy_settings': {'profile_visibility': _privacyLevel},
        }).eq('id', userId);
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paramètres enregistrés'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Paramètres', style: TextStyle(color: Color(0xFF0B1B3D), fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSection('Notifications', [
                    SwitchListTile(title: const Text('Notifications push'), subtitle: const Text('Recevoir les alertes en temps réel'), value: _pushNotifications, onChanged: (v) => setState(() => _pushNotifications = v), secondary: const Icon(Icons.notifications, color: Color(0xFFD4AF37))),
                    SwitchListTile(title: const Text('Notifications email'), subtitle: const Text('Recevoir les résumés par email'), value: _emailNotifications, onChanged: (v) => setState(() => _emailNotifications = v), secondary: const Icon(Icons.email, color: Color(0xFFD4AF37))),
                    SwitchListTile(title: const Text('Messages privés'), subtitle: const Text('Être notifié des nouveaux messages'), value: _messageNotifications, onChanged: (v) => setState(() => _messageNotifications = v), secondary: const Icon(Icons.chat, color: Color(0xFFD4AF37))),
                  ]),
                  const SizedBox(height: 16),
                  _buildSection('Confidentialité', [
                    RadioListTile(title: const Text('Public'), subtitle: const Text('Tout le monde peut voir votre profil'), value: 'public', groupValue: _privacyLevel, onChanged: (v) => setState(() => _privacyLevel = v!), secondary: const Icon(Icons.public, color: Color(0xFFD4AF37))),
                    RadioListTile(title: const Text('Mes connexions'), subtitle: const Text('Seules vos connexions peuvent voir votre profil'), value: 'connections', groupValue: _privacyLevel, onChanged: (v) => setState(() => _privacyLevel = v!), secondary: const Icon(Icons.people, color: Color(0xFFD4AF37))),
                    RadioListTile(title: const Text('Privé'), subtitle: const Text('Personne ne peut voir votre profil'), value: 'private', groupValue: _privacyLevel, onChanged: (v) => setState(() => _privacyLevel = v!), secondary: const Icon(Icons.lock, color: Color(0xFFD4AF37))),
                  ]),
                  const SizedBox(height: 16),
                  _buildSection('Actions', [
                    ListTile(leading: const Icon(Icons.block, color: Colors.red), title: const Text('Utilisateurs bloqués'), trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/network/blocked')),  // ✅ Correction
                  ]),
                  const SizedBox(height: 32),
                  ElevatedButton(onPressed: _saveSettings, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF0B1B3D), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))), child: const Text('ENREGISTRER')),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Padding(padding: const EdgeInsets.all(16), child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))), const Divider(height: 0), ...children],
      ),
    );
  }
}
