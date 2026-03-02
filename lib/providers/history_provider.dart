import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history.dart';

class HistoryProvider with ChangeNotifier {
  List<HistoryItem> _historyItems = [];

  List<HistoryItem> get historyItems => List.unmodifiable(_historyItems);

  HistoryProvider() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('calculation_history') ?? '[]';
      final List<dynamic> historyList = jsonDecode(historyJson);

      _historyItems = historyList
          .map((item) => HistoryItem.fromJson(item))
          .toList();

      // Sort by creation date (newest first)
      _historyItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      notifyListeners();
    } catch (e) {
      print('Error loading history: $e');
    }
  }

  Future<void> addHistoryItem({
    required String companyName,
    required String accountType,
    required DateTime date,
    required Map<String, dynamic> calculationData,
  }) async {
    try {
      final historyItem = HistoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        companyName: companyName,
        accountType: accountType,
        date: date,
        calculationData: calculationData,
        createdAt: DateTime.now(),
      );

      _historyItems.insert(0, historyItem);
      await _saveHistory();
      notifyListeners();
    } catch (e) {
      print('Error adding history item: $e');
    }
  }

  Future<void> addItem(HistoryItem historyItem) async {
    try {
      _historyItems.insert(0, historyItem);
      await _saveHistory();
      notifyListeners();
    } catch (e) {
      print('Error adding history item: $e');
    }
  }

  Future<void> deleteHistoryItem(String id) async {
    try {
      _historyItems.removeWhere((item) => item.id == id);
      await _saveHistory();
      notifyListeners();
    } catch (e) {
      print('Error deleting history item: $e');
    }
  }

  Future<void> clearHistory() async {
    try {
      _historyItems.clear();
      await _saveHistory();
      notifyListeners();
    } catch (e) {
      print('Error clearing history: $e');
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = jsonEncode(
        _historyItems.map((item) => item.toJson()).toList(),
      );
      await prefs.setString('calculation_history', historyJson);
    } catch (e) {
      print('Error saving history: $e');
    }
  }
}
