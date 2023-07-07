import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:spin_machine/src/spin_controller.dart';

const kMaxIndex = 50000;

class SpinRoll extends StatefulWidget {
  final SpinController? spinController;
  final List<Widget> slots;
  final Curve curve;
  final double itemExtend;
  final ScrollPhysics? scrollPhysics;

  const SpinRoll({
    Key? key,
    required this.itemExtend,
    required this.slots,
    this.scrollPhysics,
    this.spinController,
    this.curve = Curves.easeOut,
  }) : super(key: key);

  @override
  State createState() => _SpinRollState();
}

class _SpinRollState extends State<SpinRoll> {
  final InfiniteScrollController _infiniteScrollController =
      InfiniteScrollController();

  int _currentIndex = 0;
  int _topTemporaryIndex = 0;
  int _centerTemporaryIndex = 0;
  int _bottomTemporaryIndex = 0;

  late Timer _nextItemTimer;
  int _stopIndex = 0;
  bool _isStopped = false;

  @override
  void initState() {
    super.initState();
    _addSpinControllerListener();
  }

  @override
  void dispose() {
    _infiniteScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: false,
      child: InfiniteCarousel.builder(
        physics: widget.scrollPhysics ?? const BouncingScrollPhysics(),
        itemExtent: widget.itemExtend,
        controller: _infiniteScrollController,
        itemCount: widget.slots.length,
        axisDirection: Axis.vertical,
        itemBuilder: (context, index, realIndex) {
          if (widget.spinController!.state.isStopped) {
            if (realIndex == _stopIndex) {
              _centerTemporaryIndex = widget.spinController!.centerIndex;
              return widget.slots[_centerTemporaryIndex];
            } else if (realIndex == _stopIndex - 1) {
              _topTemporaryIndex = widget.spinController!.topIndex;
              return widget.slots[_topTemporaryIndex];
            } else if (realIndex == _stopIndex + 1) {
              _bottomTemporaryIndex = widget.spinController!.bottomIndex;
              return widget.slots[_bottomTemporaryIndex];
            } else {
              final random = Random().nextInt(widget.slots.length - 1);
              return widget.slots[random];
            }
          } else {
            if (realIndex == _stopIndex) {
              return widget.slots[_centerTemporaryIndex];
            } else if (realIndex == _stopIndex - 1) {
              return widget.slots[_topTemporaryIndex];
            } else if (realIndex == _stopIndex + 1) {
              return widget.slots[_bottomTemporaryIndex];
            } else {
              final random = Random().nextInt(widget.slots.length - 1);
              return widget.slots[random];
            }
          }
        },
      ),
    );
  }

  void _addSpinControllerListener() {
    if (widget.spinController != null) {
      widget.spinController!.addListener(() {
        if (widget.spinController!.state.isSpinRandomly) {
          _animate();
        }
        if (widget.spinController!.state.isStopped) {
          _stopSpin();
        }
      });
    }
  }

  Future<void> _animate() async {
    if (widget.spinController != null) {
      _nextItemTimer =
          Timer.periodic(const Duration(milliseconds: 120), (timer) async {
        _stopSlotAtIndex(
          currentRollIndex: _currentIndex % widget.slots.length,
        );
      });
    }
  }

  void _stopSlotAtIndex({required int currentRollIndex}) {
    if (_isStopped) {
      _stopIndex = _currentIndex + 10;
      _infiniteScrollController.animateToItem(
        _stopIndex,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 20 * 120),
      );
      _nextItemTimer.cancel();
      _isStopped = false;
      _currentIndex = _stopIndex;
    } else {
      _infiniteScrollController.animateToItem(
        _currentIndex,
        curve: widget.curve,
        duration: const Duration(milliseconds: 120),
      );
    }
    if (_currentIndex >= kMaxIndex) {
      _currentIndex = 0;
    } else {
      _currentIndex++;
    }
  }

  void _stopSpin() {
    if (widget.spinController != null) {
      _isStopped = true;
    }
  }
}
