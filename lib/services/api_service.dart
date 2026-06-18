import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// busca endereço pelo CEP usando a API do ViaCEP
class ApiService {
  static Future<Map<String, dynamic>?> fetchAddress(String cep) async {
    final cleaned = cep.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length != 8) return null;
    try {
      final response = await http.get(Uri.parse('https://viacep.com.br/ws/$cleaned/json/'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['erro'] == true) return null;
        return data;
      }
    } catch (e) {
      debugPrint('erro ao buscar cep: $e');
    }
    return null;
  }

  // clima atual usando a API do OpenMeteo
  static Future<Map<String, dynamic>?> fetchWeather({
    double lat = -23.5505,
    double lon = -46.6333,
  }) async {
    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$lat&longitude=$lon'
        '&current=temperature_2m,weathercode,windspeed_10m'
        '&timezone=America%2FSao_Paulo',
      );
      final response =
          await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return null;
  }

  static String weatherDescription(int code) {
    if (code == 0) return 'Céu limpo';
    if (code <= 3) return 'Parcialmente nublado';
    if (code <= 49) return 'Neblina';
    if (code <= 69) return 'Chuva';
    if (code <= 79) return 'Neve';
    if (code <= 99) return 'Tempestade';
    return 'Tempo variável';
  }
}
