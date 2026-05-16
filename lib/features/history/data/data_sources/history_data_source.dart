import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/history_model.dart';


class HistoryDataSource {
  static const _kIndexKey = 'history_index';
  static const _kPrefix = 'history_entry_';
  static const _kMaxEntries = 50;

  final SharedPreferences _prefs;

  HistoryDataSource(this._prefs);


  Future<List<AnalysisHistoryModel>> getAll() async {
    final ids = _readIndex();
    final result = <AnalysisHistoryModel>[];

    for (final id in ids) {
      final raw = _prefs.getString('$_kPrefix$id');
      if (raw == null) continue;
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        result.add(AnalysisHistoryModel.fromJson(json));
      } catch (_) {
        // entrada corrompida – ignora silenciosamente
      }
    }

    return result;
  }


  Future<void> save(AnalysisHistoryModel model) async {
    final ids = _readIndex();

    ids.remove(model.id);


    ids.insert(0, model.id);

    if (ids.length > _kMaxEntries) {
      final removed = ids.sublist(_kMaxEntries);
      ids.removeRange(_kMaxEntries, ids.length);
      for (final oldId in removed) {
        await _prefs.remove('$_kPrefix$oldId');
      }
    }

    await _prefs.setString('$_kPrefix${model.id}', jsonEncode(model.toJson()));
    await _writeIndex(ids);
  }

  Future<void> delete(String id) async {
    final ids = _readIndex();
    ids.remove(id);
    await _prefs.remove('$_kPrefix$id');
    await _writeIndex(ids);
  }

  Future<void> clearAll() async {
    final ids = _readIndex();
    for (final id in ids) {
      await _prefs.remove('$_kPrefix$id');
    }
    await _prefs.remove(_kIndexKey);
  }


  List<String> _readIndex() {
    final raw = _prefs.getString(_kIndexKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>).cast<String>();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeIndex(List<String> ids) async {
    await _prefs.setString(_kIndexKey, jsonEncode(ids));
  }
}
