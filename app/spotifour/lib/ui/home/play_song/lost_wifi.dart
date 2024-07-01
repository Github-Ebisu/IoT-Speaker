import 'dart:async';

class LostWiFiController {
  Duration _songDuration;
  late Timer _timer;
  Duration _currentDuration = Duration.zero;
  final StreamController<Duration> _progressController = StreamController.broadcast();

  LostWiFiController(this._songDuration) {
    startTimer();
  }

  Stream<Duration> get progressStream => _progressController.stream;

  Duration get currentDuration => _currentDuration;
  Duration get songDuration => _songDuration;

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentDuration += const Duration(seconds: 1);
      _progressController.add(_currentDuration);

      if (_currentDuration >= _songDuration) {
        reset();
      }
    });
  }

  void reset() {
    _currentDuration = Duration.zero;
    _progressController.add(_currentDuration);
  }

  void dispose() {
    _timer.cancel();
    _progressController.close();
  }
}
