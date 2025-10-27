import 'package:flutter/material.dart';

abstract class BaseController {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<T> handleAsync<T>(Future<T> Function() action) async {
    try {
      setLoading(true);
      final result = await action();
      return result;
    } finally {
      setLoading(false);
    }
  }

  void dispose() {
    _listeners.clear();
  }
}