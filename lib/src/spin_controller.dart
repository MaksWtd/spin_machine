import 'dart:async';

import 'package:flutter/foundation.dart';

enum SpinControllerState {
  none,
  spinRandomly,
  stopped;

  bool get isNone => this == SpinControllerState.none;

  bool get isSpinRandomly => this == SpinControllerState.spinRandomly;

  bool get isStopped => this == SpinControllerState.stopped;
}

class SpinController extends ChangeNotifier {
  SpinControllerState _state = SpinControllerState.none;

  SpinControllerState get state => _state;

  int _topIndex = 0;
  int _centerIndex = 0;
  int _bottomIndex = 0;

  int get centerIndex => _centerIndex;
  int get bottomIndex => _bottomIndex;
  int get topIndex => _topIndex;

  final int? secondsBeforeStop;

  late Timer _stopAutomaticallyTimer;

  SpinController({
    this.secondsBeforeStop,
  });

  void spinRandomly({
    required int topIndex,
    required int centerIndex,
    required int bottomIndex,
  }) {
    if (_state.isSpinRandomly) {
      return;
    }
    _topIndex = topIndex;
    _centerIndex = centerIndex;
    _bottomIndex = bottomIndex;

    _state = SpinControllerState.spinRandomly;
    if (secondsBeforeStop != null) {
      _setAutomaticallyStopTimer(secondsBeforeStop!);
    }
    notifyListeners();
  }

  void stop() {
    if (_state.isSpinRandomly) {
      _state = SpinControllerState.stopped;
      notifyListeners();
    }
  }

  void _setAutomaticallyStopTimer(int stopDuration) {
    _stopAutomaticallyTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer.tick == secondsBeforeStop) {
        if (!_state.isStopped) {
          stop();
        }
        _stopAutomaticallyTimer.cancel();
      }
    });
  }
}
