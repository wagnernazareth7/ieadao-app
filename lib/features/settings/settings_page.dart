import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ieadao/core/services/auth_service.dart';
import 'package:ieadao/core/theme/app_colors.dart';
import 'package:ieadao/core/theme/app_text_styles.dart';
import 'package:ieadao/features/auth/providers/current_user_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          // SEÇÃO DA CONTA
          _buildSectionHeader('CONTA'),
          userAsync.when(
            data: (user) => ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(user?.email.split('@')[0] ?? 'Utilizador'),
              subtitle: Text(user?.email ?? ''),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const ListTile(title: Text('Erro ao carregar dados')),
          ),
          const Divider(),

          // SEÇÃO DE PREFERÊNCIAS
          _buildSectionHeader('PREFERÊNCIAS'),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Modo Escuro'),
            trailing: Switch(value: false, onChanged: (v) {}),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_none),
            title: const Text('Notificações Push'),
            trailing: Switch(value: true, onChanged: (v) {}),
          ),
          const Divider(),

          // SEÇÃO DE SUPORTE
          _buildSectionHeader('SUPORTE'),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Centro de Ajuda'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Sobre o IEADAO App'),
            onTap: () {},
          ),
          
          const SizedBox(height: 40),
          // BOTÃO DE LOGOUT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () async => await AuthService().logout(),
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const Text('SAIR DA CONTA', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Center(child: Text('Versão 1.0.0 (Beta)', style: TextStyle(color: Colors.grey, fontSize: 12))),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
