import 'dart:async';

class ProgressBarController {
  Duration _songDuration;
  late Timer _timer;
  Duration _currentDuration = Duration.zero;
  bool _isPlaying = false;
  final StreamController<Duration> _progressController = StreamController.broadcast();

  ProgressBarController(this._songDuration) {
    startTimer();
  }

  Stream<Duration> get progressStream => _progressController.stream;

  Duration get currentDuration => _currentDuration;
  Duration get songDuration => _songDuration;

  set setIsPlaying(bool value) {
    _isPlaying = value;
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPlaying) {
        _currentDuration += const Duration(seconds: 1);
        _progressController.add(_currentDuration);

        if (_currentDuration >= _songDuration) {
          reset();
        }
      }
    });
  }

  void updateSongDuration(int newDuration) {
    _songDuration = Duration(seconds: newDuration);
    reset();
    _progressController.add(_currentDuration);
  }

  void seek(Duration position) {
    _currentDuration = position;
    _progressController.add(_currentDuration);
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
