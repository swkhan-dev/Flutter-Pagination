import 'package:flutter/material.dart';

class BaseViewmodel extends ChangeNotifier {
  ViewState _state = ViewState.idle;

  ViewState get state => _state;

  setstate(ViewState state) {
    _state = state;
    notifyListeners();
  }
}

enum ViewState { idle, loading }
