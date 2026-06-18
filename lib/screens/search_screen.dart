import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Profissionais'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // barra de busca
          Container(
            color: ZeloColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: provider.setSearchQuery,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Nome, serviço ou especialidade...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.15),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),

          // filtros
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Categorias
                SizedBox(
                  height: 44,
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
                const SizedBox(height: 12),
                // Filtro de preço
                Row(
                  children: [
                    const Text('Até ', style: TextStyle(color: ZeloColors.textSecondary, fontSize: 13)),
                    Text(
                      'R\$ ${provider.maxPrice.toStringAsFixed(0)}/h',
                      style: const TextStyle(color: ZeloColors.primary, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    Expanded(
                      child: Slider(
                        value: provider.maxPrice,
                        min: 30,
                        max: 200,
                        divisions: 17,
                        activeColor: ZeloColors.primary,
                        onChanged: provider.setMaxPrice,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // resultado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${provider.filteredProviders.length} profissionais encontrados',
                  style: const TextStyle(color: ZeloColors.textSecondary, fontSize: 13),
                ),
                const Spacer(),
                const Icon(Icons.sort, size: 18, color: ZeloColors.textSecondary),
                const SizedBox(width: 4),
                const Text('Melhor avaliados', style: TextStyle(color: ZeloColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),

          Expanded(
            child: provider.filteredProviders.isEmpty
                ? const EmptyState(
                    icon: '🔍',
                    title: 'Nenhum profissional encontrado',
                    subtitle: 'Tente ajustar o filtro ou a busca',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.filteredProviders.length,
                    itemBuilder: (_, i) {
                      final p = provider.filteredProviders[i];
                      return ProviderCard(
                        provider: p,
                        onTap: () => Navigator.pushNamed(context, '/provider', arguments: p),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _SearchBottomNav(),
    );
  }
}

class _SearchBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 1,
      onDestinationSelected: (i) {
        switch (i) {
          case 0: Navigator.pushReplacementNamed(context, '/home'); break;
          case 1: break;
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
