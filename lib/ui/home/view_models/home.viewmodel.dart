import 'package:flutter/material.dart';
import 'package:media_vault/util/command.dart';
import 'package:media_vault/util/result.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel() {
    incrementCounter = Command0(_incrementCounter);
    resetCounter = Command0(_resetCounter);
  }

  int _count = 0;
  int get count => _count;

  late Command0 incrementCounter;
  late Command0 resetCounter;

  Future<Result> _incrementCounter() async {
    try {
      _count = _count + 1;

      return Result.ok(_count);
    } finally {
      notifyListeners();
    }
  }

  Future<Result> _resetCounter() async {
    try {
      _count = 0;

      return Result.ok(_count);
    } finally {
      notifyListeners();
    }
  }
}
