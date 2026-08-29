import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../models/usuario.dart';
import '../models/pedido.dart';
import '../services/api_client.dart';

class AppProvider extends ChangeNotifier {
  // login
  bool _isLoggedIn = false;
  String _userName = '';
  String _userEmail = '';
  Usuario? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;
  Usuario? get currentUser => _currentUser;

  // filtros da busca
  String _selectedCategory = '';
  String _searchQuery = '';
  double _maxPrice = 200.0;

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  double get maxPrice => _maxPrice;

  List<Provider> get filteredProviders {
    var list = MockData.providers.toList();
    if (_selectedCategory.isNotEmpty) {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q) ||
              p.specialties.any((s) => s.toLowerCase().contains(q)))
          .toList();
    }
    list = list.where((p) => p.pricePerHour <= _maxPrice).toList();
    list.sort((a, b) => b.rating.compareTo(a.rating));
    return list;
  }

  // pedidos locais/mockados (usados pelos fluxos de agendamento e tracking)
  List<ServiceOrder> _orders = [];
  List<ServiceOrder> get orders => List.unmodifiable(_orders);

  // pedidos reais, vindos do backend (GET /pedidos)
  List<Pedido> _pedidos = [];
  bool _pedidosLoading = false;
  String? _pedidosError;

  List<Pedido> get pedidos => List.unmodifiable(_pedidos);
  bool get pedidosLoading => _pedidosLoading;
  String? get pedidosError => _pedidosError;

  // carrega o que tava salvo localmente
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString(ApiClient.tokenKey);
    final userJson = prefs.getString('currentUser');
    if (token != null && token.isNotEmpty && userJson != null) {
      _currentUser = Usuario.fromJson(jsonDecode(userJson));
      _isLoggedIn = true;
      _userName = _currentUser!.nome;
      _userEmail = _currentUser!.email;
    }

    final ordersJson = prefs.getStringList('orders') ?? [];
    _orders = ordersJson
        .map((s) => ServiceOrder.fromJson(jsonDecode(s)))
        .toList();

    notifyListeners();
  }

  Future<void> login(String email, String senha) async {
    final data = await ApiClient.instance.post(
      '/auth/login',
      auth: false,
      body: {'email': email, 'senha': senha},
    );
    await _handleAuthResponse(data as Map<String, dynamic>);
  }

  Future<void> registrar({
    required String nome,
    required String email,
    required String senha,
    required TipoUsuario tipo,
    String? telefone,
    String? endereco,
  }) async {
    final data = await ApiClient.instance.post(
      '/auth/registrar',
      auth: false,
      body: {
        'nome': nome,
        'email': email,
        'senha': senha,
        'tipo': tipo.name,
        if (telefone != null && telefone.isNotEmpty) 'telefone': telefone,
        if (endereco != null && endereco.isNotEmpty) 'endereco': endereco,
      },
    );
    await _handleAuthResponse(data as Map<String, dynamic>);
  }

  Future<void> _handleAuthResponse(Map<String, dynamic> data) async {
    final token = data['token'] as String;
    final usuario = Usuario.fromJson(data['usuario'] as Map<String, dynamic>);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiClient.tokenKey, token);
    await prefs.setString('currentUser', jsonEncode(usuario.toJson()));

    _isLoggedIn = true;
    _currentUser = usuario;
    _userName = usuario.nome;
    _userEmail = usuario.email;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = false;
    _userName = '';
    _userEmail = '';
    _currentUser = null;
    _pedidos = [];
    _pedidosError = null;
    await prefs.remove(ApiClient.tokenKey);
    await prefs.remove('currentUser');
    notifyListeners();
  }

  Future<void> fetchPedidos() async {
    _pedidosLoading = true;
    _pedidosError = null;
    notifyListeners();
    try {
      final data = await ApiClient.instance.get('/pedidos');
      final todosPedidos = (data as List)
          .map((e) => Pedido.fromJson(e as Map<String, dynamic>))
          .toList();
      // GET /pedidos retorna os pedidos de todos os clientes — filtramos aqui
      // para mostrar somente os do usuário logado.
      _pedidos = todosPedidos.where((p) => p.cliente?.id == _currentUser?.id).toList();
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await logout();
      }
      _pedidosError = e.message;
    } finally {
      _pedidosLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    _selectedCategory = _selectedCategory == category ? '' : category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setMaxPrice(double price) {
    _maxPrice = price;
    notifyListeners();
  }

  Future<void> createOrder(ServiceOrder order) async {
    _orders.insert(0, order);
    final prefs = await SharedPreferences.getInstance();
    final encoded = _orders.map((o) => jsonEncode(o.toJson())).toList();
    await prefs.setStringList('orders', encoded);
    notifyListeners();
  }

  Future<void> cancelOrder(String orderId) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;
    final old = _orders[index];
    _orders[index] = ServiceOrder(
      id: old.id,
      providerId: old.providerId,
      providerName: old.providerName,
      service: old.service,
      scheduledDate: old.scheduledDate,
      totalPrice: old.totalPrice,
      status: OrderStatus.cancelled,
      address: old.address,
    );
    final prefs = await SharedPreferences.getInstance();
    final encoded = _orders.map((o) => jsonEncode(o.toJson())).toList();
    await prefs.setStringList('orders', encoded);
    notifyListeners();
  }
}
