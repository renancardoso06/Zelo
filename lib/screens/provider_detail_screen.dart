import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme.dart';

class ProviderDetailScreen extends StatelessWidget {
  const ProviderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = ModalRoute.of(context)!.settings.arguments as Provider;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: ZeloColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ZeloColors.primary, Color(0xFF154360)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundImage: NetworkImage(provider.avatarUrl),
                            backgroundColor: Colors.white24,
                          ),
                          if (provider.isVerified)
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const Icon(Icons.verified, color: ZeloColors.accent, size: 20),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(provider.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                      Text(provider.category, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _StatCard(icon: '⭐', value: provider.rating.toString(), label: 'Avaliação'),
                      const SizedBox(width: 12),
                      _StatCard(icon: '✅', value: provider.completedJobs.toString(), label: 'Serviços'),
                      const SizedBox(width: 12),
                      _StatCard(icon: '💬', value: provider.reviewCount.toString(), label: 'Avaliações'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ZeloColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ZeloColors.primary.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.attach_money, color: ZeloColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'R\$ ${provider.pricePerHour.toStringAsFixed(0)}/hora',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ZeloColors.primary),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: ZeloColors.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Disponível', style: TextStyle(color: ZeloColors.accent, fontWeight: FontWeight.w600, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text('Sobre', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ZeloColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text(provider.description, style: const TextStyle(color: ZeloColors.textSecondary, fontSize: 14, height: 1.6)),
                  const SizedBox(height: 20),

                  const Text('Especialidades', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ZeloColors.textPrimary)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: provider.specialties.map((s) =>
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: ZeloColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: ZeloColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Text(s, style: const TextStyle(color: ZeloColors.primary, fontWeight: FontWeight.w500, fontSize: 13)),
                      ),
                    ).toList(),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: ZeloColors.textSecondary, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '${provider.neighborhood} • São Paulo, SP',
                        style: const TextStyle(color: ZeloColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (provider.isVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: ZeloColors.accent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.shield_outlined, color: ZeloColors.accent, size: 18),
                          SizedBox(width: 8),
                          Text('Antecedentes verificados pela Zelo', style: TextStyle(color: ZeloColors.accent, fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/schedule', arguments: provider),
            icon: const Icon(Icons.calendar_today_outlined),
            label: const Text('Agendar serviço'),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const _StatCard({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: ZeloColors.textPrimary)),
            Text(label, style: const TextStyle(fontSize: 11, color: ZeloColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
