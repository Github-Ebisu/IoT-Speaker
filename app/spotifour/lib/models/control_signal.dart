class ControlSignal {
  bool update;
  bool finished;
  bool play;
  int songID;
  int volume;

  ControlSignal({
    required this.update,
    required this.finished,
    required this.play,
    required this.songID,
    required this.volume,
  });
}
