import 'package:flutter/widgets.dart';

class FocusLifecycleObserver extends WidgetsBindingObserver {
  FocusLifecycleObserver({
    required this.isSessionActive,
    required this.onBackgrounded,
    required this.onForegrounded,
  });

  final bool Function() isSessionActive;
  final VoidCallback onBackgrounded;
  final VoidCallback onForegrounded;

  bool _penaltyAlreadyApplied = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isBackgroundState(state) && isSessionActive() && !_penaltyAlreadyApplied) {
      _penaltyAlreadyApplied = true;
      onBackgrounded();
    }

    if (state == AppLifecycleState.resumed) {
      onForegrounded();
    }
  }

  void resetPenaltyLock() {
    _penaltyAlreadyApplied = false;
  }

  bool _isBackgroundState(AppLifecycleState state) {
    return state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden;
  }
}
