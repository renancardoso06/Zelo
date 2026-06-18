import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class AppProvider extends ChangeNotifier {
  // login
  bool _isLoggedIn = false;
  String _userName = '';
  String _userEmail = '';

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;

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

  // pedidos do usuário
  List<ServiceOrder> _orders = [];
  List<ServiceOrder> get orders => List.unmodifiable(_orders);

  // carrega o que tava salvo localmente
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _userName = prefs.getString('userName') ?? '';
    _userEmail = prefs.getString('userEmail') ?? '';

    final ordersJson = prefs.getStringList('orders') ?? [];
    _orders = ordersJson
        .map((s) => ServiceOrder.fromJson(jsonDecode(s)))
        .toList();

    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    // Simulação de login — em produção, chama API
    await Future.delayed(const Duration(milliseconds: 800));
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = true;
    _userName = email.split('@').first;
    _userEmail = email;
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userName', _userName);
    await prefs.setString('userEmail', _userEmail);
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = false;
    _userName = '';
    _userEmail = '';
    await prefs.remove('isLoggedIn');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    notifyListeners();
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
