import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  ApiService();

  static const String _baseUrl = 'https://api.currencyapi.com/v3';

  Future<double> getRate({
    required String from,
    required String to,
  }) async {
    final apiKey = dotenv.env['EXCHANGE_RATE_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Cle API manquante');
    }

    final base = from.toUpperCase();
    final target = to.toUpperCase();

    final uri = Uri.parse('$_baseUrl/latest').replace(
      queryParameters: {
        'base_currency': base,
        'currencies': target,
      },
    );
    final response = await http.get(
      uri,
      headers: {'apikey': apiKey},
    );

    if (response.statusCode != 200) {
      throw Exception('API error (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['message'] is String) {
      throw Exception(data['message'] as String);
    }
    if (data['success'] == false) {
      final message = (data['error'] as Map?)?['message']?.toString();
      throw Exception(message ?? 'API error');
    }

    final rate = _extractRate(data, target);
    if (rate != null) {
      return rate;
    }

    throw Exception('Taux introuvable');
  }
}

double? _extractRate(Map<String, dynamic> data, String to) {
  final target = to.toUpperCase();

  double? asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  dynamic rates = data['rates'];
  if (rates == null && data['data'] is Map) {
    final inner = data['data'] as Map;
    rates = inner['rates'] ?? inner['exchange_rates'];
  }

  if (rates is Map) {
    final direct =
        rates[target] ?? rates[target.toLowerCase()] ?? rates[target];
    final directValue = asDouble(direct);
    if (directValue != null) return directValue;

    for (final entry in rates.entries) {
      final key = entry.key.toString().toUpperCase();
      if (key == target || key.endsWith(target)) {
        final value = asDouble(entry.value);
        if (value != null) return value;
      }
    }
  }

  if (data['data'] is Map) {
    final map = data['data'] as Map;
    final direct = map[target] ?? map[target.toLowerCase()] ?? map[target];
    if (direct is Map) {
      final value = asDouble(direct['value']);
      if (value != null) return value;
    }
    final directValue = asDouble(direct);
    if (directValue != null) return directValue;
  }

  if (rates is List) {
    for (final item in rates) {
      if (item is Map) {
        final code = (item['code'] ?? item['symbol'] ?? item['currency'])
            ?.toString()
            .toUpperCase();
        final value = asDouble(item['rate'] ?? item['value']);
        if (code == target && value != null) return value;
      }
    }
  }

  final directResult = data['result'] ??
      data['conversion_rate'] ??
      (data['info'] is Map ? (data['info'] as Map)['rate'] : null);
  final directValue = asDouble(directResult);
  if (directValue != null) return directValue;

  return null;
}
