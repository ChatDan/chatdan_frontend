import 'package:flutter/material.dart';

class SquareProvider extends ChangeNotifier {
  int? _currentDivisionId;

  int? get currentDivisionId => _currentDivisionId;

  set currentDivisionId(int? currentDivisionId) {
    _currentDivisionId = currentDivisionId;
    notifyListeners();
  }
}