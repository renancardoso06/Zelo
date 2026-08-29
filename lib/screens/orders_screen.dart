import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../models/pedido.dart';
import '../providers/app_provider.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().fetchPedidos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    if (!appProvider.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pedidos'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<AppProvider>().fetchPedidos(),
        child: _buildBody(appProvider),
      ),
      bottomNavigationBar: _OrdersBottomNav(),
    );
  }

  Widget _buildBody(AppProvider appProvider) {
    // Card único e fixo (MockData.demoOrder), só para manter acessível o
    // botão "Acompanhar em tempo real" (AI Logistics Extension). Não tem
    // relação com os pedidos reais da seção "Pedidos" logo abaixo.
    final children = <Widget>[
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(
          'Demonstração — Acompanhamento em Tempo Real',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: ZeloColors.textPrimary),
        ),
      ),
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Text(
          'Exemplo fixo para testar o acompanhamento em tempo real — não é um pedido de verdade.',
          style: TextStyle(fontSize: 12, color: ZeloColors.textSecondary),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: _LocalOrderCard(order: MockData.demoOrder),
      ),
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Text(
          'Pedidos',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: ZeloColors.textPrimary),
        ),
      ),
      ..._buildPedidosSection(appProvider),
    ];

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      children: children,
    );
  }

  List<Widget> _buildPedidosSection(AppProvider appProvider) {
    if (appProvider.pedidosLoading && appProvider.pedidos.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (appProvider.pedidosError != null && appProvider.pedidos.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              const Text(
                'Não foi possível carregar seus pedidos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ZeloColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                appProvider.pedidosError!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: ZeloColors.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => context.read<AppProvider>().fetchPedidos(),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ];
    }

    if (appProvider.pedidos.isEmpty) {
      return const [
        EmptyState(
          icon: '📋',
          title: 'Nenhum pedido ainda',
          subtitle: 'Agende um serviço e ele aparecerá aqui',
        ),
      ];
    }

    return appProvider.pedidos
        .map((p) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _PedidoCard(pedido: p),
            ))
        .toList();
  }
}

// Card do pedido local/simulado (criado em schedule_screen.dart), com as
// ações originais de cancelar e acompanhar em tempo real (tracking demo).
class _LocalOrderCard extends StatelessWidget {
  final ServiceOrder order;
  const _LocalOrderCard({required this.order});

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

class _PedidoCard extends StatelessWidget {
  final Pedido pedido;
  const _PedidoCard({required this.pedido});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat("dd/MM/yyyy 'às' HH:mm");
    final servicoNome = pedido.servico?.nome ?? 'Serviço';
    final preco = pedido.servico?.precoBase ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    servicoNome,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: ZeloColors.textPrimary),
                  ),
                ),
                _StatusPedidoBadge(status: pedido.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 15, color: ZeloColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  pedido.prestador?.nome ?? 'Aguardando prestador',
                  style: const TextStyle(color: ZeloColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
            if (pedido.dataAgendamento != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 15, color: ZeloColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(fmt.format(pedido.dataAgendamento!), style: const TextStyle(color: ZeloColors.textSecondary, fontSize: 13)),
                ],
              ),
            ],
            if (pedido.enderecoAtendimento != null && pedido.enderecoAtendimento!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 15, color: ZeloColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      pedido.enderecoAtendimento!,
                      style: const TextStyle(color: ZeloColors.textSecondary, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const Divider(height: 20),
            Text(
              'R\$ ${preco.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: ZeloColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPedidoBadge extends StatelessWidget {
  final StatusPedido status;
  const _StatusPedidoBadge({required this.status});

  Color get _color {
    switch (status) {
      case StatusPedido.PENDENTE:
        return ZeloColors.warning;
      case StatusPedido.ACEITO:
        return ZeloColors.primary;
      case StatusPedido.EM_ANDAMENTO:
        return Colors.orange;
      case StatusPedido.CONCLUIDO:
        return ZeloColors.accent;
      case StatusPedido.CANCELADO:
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
        style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w600),
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
