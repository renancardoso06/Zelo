import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [ZeloColors.primary, Color(0xFF2980B9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      provider.userName.isNotEmpty ? provider.userName[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(provider.userName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(provider.userEmail, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _ProfileTile(icon: Icons.receipt_long_outlined, label: 'Meus pedidos', onTap: () => Navigator.pushNamed(context, '/orders')),
                  _ProfileTile(icon: Icons.location_on_outlined, label: 'Meus endereços', onTap: () {}),
                  _ProfileTile(icon: Icons.notifications_outlined, label: 'Notificações', onTap: () {}),
                  _ProfileTile(icon: Icons.lock_outlined, label: 'Privacidade e LGPD', onTap: () => _showLgpd(context)),
                  _ProfileTile(icon: Icons.help_outline, label: 'Suporte', onTap: () {}),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Créditos do app
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ZeloColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ZeloColors.divider),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.favorite_rounded, color: ZeloColors.primary, size: 18),
                            SizedBox(width: 8),
                            Text('Sobre o Zelo', style: TextStyle(fontWeight: FontWeight.w700, color: ZeloColors.textPrimary)),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text('Versão 1.0.0 — 2026', style: TextStyle(color: ZeloColors.textSecondary, fontSize: 13)),
                        SizedBox(height: 4),
                        Text('Desenvolvido por:', style: TextStyle(color: ZeloColors.textSecondary, fontSize: 13)),
                        SizedBox(height: 4),
                        Text('• Renan Cardoso da Costa — RM 557918', style: TextStyle(fontSize: 13, color: ZeloColors.textPrimary)),
                        Text('• Victor Vieira Borges — RM 557922', style: TextStyle(fontSize: 13, color: ZeloColors.textPrimary)),
                        SizedBox(height: 4),
                        Text('FIAP — 2026', style: TextStyle(color: ZeloColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        provider.logout();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      icon: const Icon(Icons.logout, color: ZeloColors.error),
                      label: const Text('Sair', style: TextStyle(color: ZeloColors.error)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: ZeloColors.error),
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLgpd(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Privacidade e LGPD'),
        content: const SingleChildScrollView(
          child: Text(
            'O Zelo coleta seus dados pessoais (nome, e-mail, localização) '
            'com seu consentimento explícito, conforme a LGPD (Lei 13.709/2018).\n\n'
            'Você pode solicitar a exclusão dos seus dados a qualquer momento '
            'pelo e-mail privacidade@zelo.com.br.\n\n'
            'Seus dados não são vendidos a terceiros.',
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Entendi'))],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: ZeloColors.primary),
      title: Text(label, style: const TextStyle(fontSize: 15)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: ZeloColors.textSecondary),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
