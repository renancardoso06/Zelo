import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/models.dart';
import '../theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  Position? _userPosition;
  bool _loadingLocation = true;
  String? _locationError;
  Provider? _selectedProvider;

  // SP como fallback
  static const _defaultPosition = LatLng(-23.5505, -46.6333);

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() { _locationError = 'GPS desativado'; _loadingLocation = false; });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() { _locationError = 'Permissão de localização negada'; _loadingLocation = false; });
          return;
        }
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() { _userPosition = pos; _loadingLocation = false; });
      _controller?.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(pos.latitude, pos.longitude), 13,
      ));
    } catch (e) {
      setState(() { _locationError = 'Erro ao obter localização'; _loadingLocation = false; });
    }
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    // Marcador do usuário
    if (_userPosition != null) {
      markers.add(Marker(
        markerId: const MarkerId('user'),
        position: LatLng(_userPosition!.latitude, _userPosition!.longitude),
        infoWindow: const InfoWindow(title: 'Você está aqui'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
    }

    // Marcadores dos prestadores
    for (final p in MockData.providers) {
      markers.add(Marker(
        markerId: MarkerId(p.id),
        position: LatLng(p.latitude, p.longitude),
        infoWindow: InfoWindow(title: p.name, snippet: '${p.category} • R\$ ${p.pricePerHour.toStringAsFixed(0)}/h'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        onTap: () => setState(() => _selectedProvider = p),
      ));
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final center = _userPosition != null
        ? LatLng(_userPosition!.latitude, _userPosition!.longitude)
        : _defaultPosition;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profissionais no Mapa'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.white),
            onPressed: _getUserLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (c) => _controller = c,
            initialCameraPosition: CameraPosition(target: center, zoom: 13),
            markers: _buildMarkers(),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // Legenda
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.circle, color: Colors.green, size: 12),
                  const SizedBox(width: 6),
                  Text('${MockData.providers.length} profissionais disponíveis',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),

          // Erro de localização
          if (_locationError != null)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: ZeloColors.warning.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_locationError!, style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),

          // Card do prestador selecionado
          if (_selectedProvider != null)
            Positioned(
              bottom: 80,
              left: 16,
              right: 16,
              child: _ProviderMapCard(
                provider: _selectedProvider!,
                onClose: () => setState(() => _selectedProvider = null),
                onTap: () => Navigator.pushNamed(context, '/provider', arguments: _selectedProvider),
              ),
            ),

          // Loading
          if (_loadingLocation)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)]),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: ZeloColors.primary)),
                      SizedBox(width: 10),
                      Text('Obtendo localização...', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _MapBottomNav(),
    );
  }
}

class _ProviderMapCard extends StatelessWidget {
  final Provider provider;
  final VoidCallback onClose;
  final VoidCallback onTap;

  const _ProviderMapCard({required this.provider, required this.onClose, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(radius: 28, backgroundImage: NetworkImage(provider.avatarUrl)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(provider.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    Text('${provider.category} • ⭐ ${provider.rating}', style: const TextStyle(color: ZeloColors.textSecondary, fontSize: 12)),
                    Text('R\$ ${provider.pricePerHour.toStringAsFixed(0)}/h • ${provider.neighborhood}',
                        style: const TextStyle(color: ZeloColors.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(icon: const Icon(Icons.close, size: 18), onPressed: onClose),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: ZeloColors.textSecondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 2,
      onDestinationSelected: (i) {
        switch (i) {
          case 0: Navigator.pushReplacementNamed(context, '/home'); break;
          case 1: Navigator.pushReplacementNamed(context, '/search'); break;
          case 2: break;
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
