import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/models.dart';
import '../theme.dart';

// card que mostra o prestador na lista
class ProviderCard extends StatelessWidget {
  final Provider provider;
  final VoidCallback onTap;

  const ProviderCard({
    super.key,
    required this.provider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage(provider.avatarUrl),
                    backgroundColor: ZeloColors.divider,
                  ),
                  if (provider.isVerified)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified,
                          color: ZeloColors.accent,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          provider.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: ZeloColors.textPrimary,
                          ),
                        ),
                        Text(
                          'R\$ ${provider.pricePerHour.toStringAsFixed(0)}/h',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: ZeloColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${provider.category} • ${provider.neighborhood}',
                      style: const TextStyle(
                        color: ZeloColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: provider.rating,
                          itemBuilder: (_, __) => const Icon(
                            Icons.star,
                            color: Color(0xFFF4C430),
                          ),
                          itemCount: 5,
                          itemSize: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${provider.rating} (${provider.reviewCount})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: ZeloColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${provider.completedJobs} serviços',
                          style: const TextStyle(
                            fontSize: 12,
                            color: ZeloColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: provider.specialties
                          .take(2)
                          .map(
                            (s) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: ZeloColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                s,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: ZeloColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// badge coloridinho com o status do pedido
class StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const StatusBadge({super.key, required this.status});

  Color get _color {
    switch (status) {
      case OrderStatus.pending:
        return ZeloColors.warning;
      case OrderStatus.confirmed:
        return ZeloColors.primary;
      case OrderStatus.inProgress:
        return Colors.orange;
      case OrderStatus.completed:
        return ZeloColors.accent;
      case OrderStatus.cancelled:
        return ZeloColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: _color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// chip de categoria (faxina, jardinagem...)
class CategoryChip extends StatelessWidget {
  final ServiceCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? ZeloColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? ZeloColors.primary : ZeloColors.divider,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ZeloColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(category.icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              category.name,
              style: TextStyle(
                color: isSelected ? Colors.white : ZeloColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// quando não tem nenhum resultado pra mostrar
class EmptyState extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ZeloColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: ZeloColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
