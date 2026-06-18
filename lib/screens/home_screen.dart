import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _weather;
  bool _loadingWeather = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    final data = await ApiService.fetchWeather();
    if (mounted) setState(() { _weather = data; _loadingWeather = false; });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: ZeloColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: ZeloColors.primary,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: _showNotificationDemo,
              ),
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, '/profile'),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ZeloColors.primary, Color(0xFF2980B9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.favorite_rounded, color: Colors.white, size: 22),
                            SizedBox(width: 8),
                            Text('Zelo', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Olá, ${provider.userName.isEmpty ? 'Usuário' : provider.userName} 👋',
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Widget de clima (API real)
                            _loadingWeather
                                ? const SizedBox(width: 50, child: LinearProgressIndicator(color: Colors.white54, backgroundColor: Colors.white24))
                                : _weather != null
                                    ? _WeatherWidget(data: _weather!)
                                    : const SizedBox(),
                          ],
                        ),
                        const Text(
                          'Que serviço você precisa hoje?',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
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
                  TextField(
                    onChanged: provider.setSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Buscar serviço ou profissional...',
                      prefixIcon: const Icon(Icons.search, color: ZeloColors.textSecondary),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.map_outlined, color: ZeloColors.primary),
                        onPressed: () => Navigator.pushNamed(context, '/map'),
                        tooltip: 'Ver no mapa',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text('Categorias', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: ZeloColors.textPrimary)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 52,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: MockData.categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final cat = MockData.categories[i];
                        return CategoryChip(
                          category: cat,
                          isSelected: provider.selectedCategory == cat.name,
                          onTap: () => provider.setCategory(cat.name),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  _HighlightBanner(
                    onTap: () => Navigator.pushNamed(context, '/search'),
                  ),
                  const SizedBox(height: 24),

                  // prestadores em destaque
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        provider.selectedCategory.isEmpty
                            ? 'Profissionais em destaque'
                            : provider.selectedCategory,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: ZeloColors.textPrimary),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/search'),
                        child: const Text('Ver todos'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // lista de prestadores
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final list = provider.filteredProviders.take(3).toList();
                  if (list.isEmpty) {
                    return const EmptyState(
                      icon: '🔍',
                      title: 'Nenhum profissional encontrado',
                      subtitle: 'Tente outro filtro ou categoria',
                    );
                  }
                  if (i >= list.length) return null;
                  return ProviderCard(
                    provider: list[i],
                    onTap: () => Navigator.pushNamed(context, '/provider', arguments: list[i]),
                  );
                },
                childCount: provider.filteredProviders.isEmpty ? 1 : provider.filteredProviders.take(3).length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
      bottomNavigationBar: const _BottomNav(currentIndex: 0),
    );
  }

  void _showNotificationDemo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.notifications_active, color: ZeloColors.accent),
          SizedBox(width: 8),
          Text('Notificação FCM'),
        ]),
        content: const Text(
          '✅ Serviço confirmado!\nMaria Silva confirmou a faxina para amanhã às 9h.\n\n(Simulação de push notification via Firebase Cloud Messaging)',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }
}

class _WeatherWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  const _WeatherWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    final current = data['current'] as Map<String, dynamic>?;
    if (current == null) return const SizedBox();
    final temp = current['temperature_2m'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$temp°C',
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _HighlightBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _HighlightBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B4F72), Color(0xFF2ECC71)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Profissionais verificados', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  SizedBox(height: 4),
                  Text('Segurança para\nsua família', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, height: 1.2)),
                  SizedBox(height: 12),
                  Text('Ver disponíveis →', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Text('🛡️', style: TextStyle(fontSize: 56)),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (i) {
        switch (i) {
          case 0: Navigator.pushReplacementNamed(context, '/home'); break;
          case 1: Navigator.pushReplacementNamed(context, '/search'); break;
          case 2: Navigator.pushReplacementNamed(context, '/map'); break;
          case 3: Navigator.pushReplacementNamed(context, '/orders'); break;
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
