import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<AppProvider>().orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pedidos'),
        automaticallyImplyLeading: false,
      ),
      body: orders.isEmpty
          ? const EmptyState(
              icon: '📋',
              title: 'Nenhum pedido ainda',
              subtitle: 'Agende um serviço e ele aparecerá aqui',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _OrderCard(order: orders[i]),
            ),
      bottomNavigationBar: _OrdersBottomNav(),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final ServiceOrder order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat("dd/MM/yyyy 'às' HH:mm");

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.service,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: ZeloColors.textPrimary),
                ),
                StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 15, color: ZeloColors.textSecondary),
                const SizedBox(width: 6),
                Text(order.providerName, style: const TextStyle(color: ZeloColors.textSecondary, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 15, color: ZeloColors.textSecondary),
                const SizedBox(width: 6),
                Text(fmt.format(order.scheduledDate), style: const TextStyle(color: ZeloColors.textSecondary, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 15, color: ZeloColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    order.address,
                    style: const TextStyle(color: ZeloColors.textSecondary, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'R\$ ${order.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: ZeloColors.primary),
                ),
                if (order.status == OrderStatus.confirmed || order.status == OrderStatus.pending)
                  TextButton.icon(
                    onPressed: () => _confirmCancel(context, order.id),
                    icon: const Icon(Icons.cancel_outlined, size: 16),
                    label: const Text('Cancelar'),
                    style: TextButton.styleFrom(foregroundColor: ZeloColors.error),
                  ),
              ],
            ),
            if (order.status == OrderStatus.confirmed || order.status == OrderStatus.inProgress) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/tracking', arguments: order),
                icon: const Icon(Icons.location_on_outlined, size: 16),
                label: const Text('Acompanhar em tempo real'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ZeloColors.primary,
                  side: const BorderSide(color: ZeloColors.primary),
                  minimumSize: const Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancelar pedido?'),
        content: const Text('Tem certeza que deseja cancelar este agendamento?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Não')),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().cancelOrder(orderId);
              Navigator.pop(context);
            },
            child: const Text('Sim, cancelar', style: TextStyle(color: ZeloColors.error)),
          ),
        ],
      ),
    );
  }
}

class _OrdersBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 3,
      onDestinationSelected: (i) {
        switch (i) {
          case 0: Navigator.pushReplacementNamed(context, '/home'); break;
          case 1: Navigator.pushReplacementNamed(context, '/search'); break;
          case 2: Navigator.pushReplacementNamed(context, '/map'); break;
          case 3: break;
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
        NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search), label: 'Buscar'),
        NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Mapa'),
        NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Pedidos'),
      ],
    );
  }
}
