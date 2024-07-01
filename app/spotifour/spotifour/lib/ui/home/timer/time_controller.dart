import 'dart:async';

class TimeController {
  int hours = 0;
  int minutes = 0;
  int seconds = 0;

  late Duration _duration;
  late Timer _timer;
  late TimeState _state;

  final StreamController<Duration> _timeController = StreamController.broadcast();

  TimeController() {
    _duration = Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
    _state = TimeState.init;
  }

  Stream<Duration> get progressStream => _timeController.stream;
  Timer? get timer => _timer;
  Duration get totalDuration => Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
      );

  Duration get currentDuration => _duration;

  TimeState get state => _state;
  void set state(TimeState currentState) {
    _state = currentState;
  }

  void setDuration({required int hours, required int minutes, required int seconds}) {
    this.hours = hours;
    this.minutes = minutes;
    this.seconds = seconds;
    _duration = Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
    _timeController.add(_duration); // Update the stream with the new duration
  }

  void startTimer() {
    _state = TimeState.run;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_duration > const Duration(seconds: 0)) {
        _duration -= const Duration(seconds: 1);
        _timeController.add(_duration); // Update the stream with the new duration
      } else {
        _state = TimeState.finish;
        stopTimer();
      }
    });
  }

  void stopTimer() {
    _timer.cancel();
  }

  void reset() {
    final totalDuration = Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
    _duration = totalDuration;
    _timeController.add(totalDuration);
  }

  void dispose() {
    _state = TimeState.finish;
    _timer.cancel();
    _timeController.close();
  }

  void closeStream() {
    _timeController.close();
  }
}

// Enum to define the various states of the timer
enum TimeState { init, run, stop, reset, finish }
