import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

class OfflineCacheService {
  static const String _boxName = 'offline_cache_v1';
  static Box<String>? _box;

  static Future<Box<String>> _openBox() async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    if (Hive.isBoxOpen(_boxName)) {
      _box = Hive.box<String>(_boxName);
      return _box!;
    }
    _box = await Hive.openBox<String>(_boxName);
    return _box!;
  }

  static Future<void> saveList(
    String key,
    List<Map<String, dynamic>> records,
  ) async {
    final box = await _openBox();
    final normalized = records.map(_normalizeMap).toList();
    await box.put(key, jsonEncode(normalized));
  }

  static Future<List<Map<String, dynamic>>> readList(String key) async {
    final box = await _openBox();
    final raw = box.get(key);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <Map<String, dynamic>>[];
      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  static Future<void> saveMap(String key, Map<String, dynamic>? record) async {
    final box = await _openBox();
    if (record == null) {
      await box.delete(key);
      return;
    }
    await box.put(key, jsonEncode(_normalizeMap(record)));
  }

  static Future<Map<String, dynamic>?> readMap(String key) async {
    final box = await _openBox();
    final raw = box.get(key);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _normalizeMap(Map<String, dynamic> map) {
    final out = <String, dynamic>{};
    map.forEach((key, value) {
      out[key] = _normalizeValue(value);
    });
    return out;
  }

  static dynamic _normalizeValue(dynamic value) {
    if (value == null || value is num || value is bool || value is String) {
      return value;
    }
    if (value is DateTime) {
      return value.toIso8601String();
    }
    if (value is Map) {
      return value.map(
        (k, v) => MapEntry(k.toString(), _normalizeValue(v)),
      );
    }
    if (value is List) {
      return value.map(_normalizeValue).toList();
    }
    return value.toString();
  }
}
