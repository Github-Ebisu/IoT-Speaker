import 'dart:async';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:spotifour/models/control_signal.dart';
import 'package:spotifour/ui/home/play_song/lost_wifi.dart';
import 'package:spotifour/ui/home/timer/time_controller.dart';
import 'package:toastification/toastification.dart';

import '../../../cloud_functions/realtime_db.dart';
import '../../../models/song.dart';
import '../timer/time_navigator.dart';
import 'progress_bar_controller.dart';

class PlaySong extends StatelessWidget {
  final Song playingSong;
  final List<Song> songs;
  final int position;

  const PlaySong({
    super.key,
    required this.songs,
    required this.playingSong,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return PlaySongPage(
      songs: songs,
      playingSong: playingSong,
      position: position,
    );
  }
}

class PlaySongPage extends StatefulWidget {
  final List<Song> songs;
  final Song playingSong;
  final int position;

  const PlaySongPage({
    super.key,
    required this.songs,
    required this.playingSong,
    required this.position,
  });

  @override
  State<PlaySongPage> createState() => _PlaySongPageState();
}

class _PlaySongPageState extends State<PlaySongPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late int _selectedItemIndex;
  late Song _song;
  late Song _nextSong;

  late double _currentAnimationPosition;

  late RealTimeDBService _realTimeDBService;
  late StreamSubscription _playStream;
  late StreamSubscription _songStream;

  late StreamSubscription _stopStream;

  late ProgressBarController _progressBarController;

  // Count down
  late bool _isBottomSheetOpen;
  late TimeController _timeController;

  // Control
  // 01
  late bool _isPlaying;
  late bool _isShuffle;
  late bool _isRepeat;
  late bool _isNext;
  late bool _isPre;
  late double _volume;

  // late double _preVolume;

  //02
  late bool _updateSong;
  late bool _updatePlay;
  late bool _updateStop;

  //03
  late bool _isWating;

  late StreamController<bool> _isWaitingController;
  late StreamSubscription<bool> _isWaitingSubscription;
  late LostWiFiController _progressLostWiFi;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _realTimeDBService = RealTimeDBService();

    _song = widget.playingSong;
    _currentAnimationPosition = 0.0;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    );

    _selectedItemIndex = widget.position;

    // Control
    _isPlaying = false;
    _isShuffle = false;
    _isRepeat = false;
    _isNext = false;
    _isPre = false;
    _volume = 0.0;

    // Update
    _updateSong = false;
    _updatePlay = false;
    _updateStop = false;

    // Init
    _initControlValue();
    _activateListenEspPub();
    _progressBarController = ProgressBarController(Duration(seconds: _song.duration));
    _timeController = TimeController();
    _activateListenDuration();
    _getVolume();

    // Count down
    _isBottomSheetOpen = false;
    _activateListenCountDown();

    // Waiting

    _isWating = false;
    _progressLostWiFi = LostWiFiController(const Duration(seconds: 10));
    _activateListenLostWiFi();
  }

  void _initControlValue() async {
    ControlSignal controlSignal = ControlSignal(
      update: false,
      finished: false,
      play: true,
      songID: widget.position + 1,
      volume: 0,
    );
    await _realTimeDBService.updateMultipleControlSignals(controlSignal);
  }

  void _resetControl() async {
    await _realTimeDBService.resetControl();
  }

  _activateListenLostWiFi() {
    _progressLostWiFi.progressStream.listen((duration) async {
      print("Time 0: $duration");
      if (duration >= _progressLostWiFi.songDuration) {
        if (_isWating) {
          toastification.show(
            type: ToastificationType.error,
            style: ToastificationStyle.minimal,
            direction: TextDirection.ltr,
            alignment: Alignment.topRight,
            title: const Text("ESP 32 lost WiFi connection"),
            autoCloseDuration: const Duration(seconds: 3),
          );
          if (_isBottomSheetOpen) {
            Navigator.pop(context); // Close the bottom sheet
          }
          Navigator.pop(context); // Close the PlaySongPage
        }
      }
    });
  }

  void _activateListenCountDown() {
    _timeController.progressStream.listen((duration) async {
      print("Time 1: $duration");
      if (duration <= Duration.zero) {
        _progressBarController.reset();
        setState(() {
          _isWating = true;
        });
        await _realTimeDBService.updateOnceControlSignal("stop", true);
      }
    });
  }

  void _getVolume() {
    _realTimeDBService.getControl("volume").then((value) {
      setState(() {
        _volume = (value != null && value <= 10) ? (value as int).toDouble() : 0.0;
      });
    });
  }

  _activateListenDuration() {
    _progressBarController.progressStream.listen((duration) async {
      print("Time 2: $duration");

      if (duration >= _progressBarController.songDuration) {
        if (_isRepeat == true) {
          _progressBarController.reset();
          setState(() {
            _isPlaying = false;
            _isWating = true;
          });
          await _realTimeDBService.updateOnceControlSignal("finished", true);
        } else {
          _setNextSong();
        }
      }
    });
  }

  void _activateListenEspPub() {
    _playStream = FirebaseDatabase.instance.ref().child("Control/ESP_Pub").onValue.listen((event) async {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      print("Data: $data");
      final update = data['updatePlay'];
      setState(() {
        _updatePlay = update;
      });

      if (_updatePlay == true && _isPlaying == true) {
        setState(() {
          _isPlaying = false;
          _isWating = false;

          // _isWaitingController.add(false);
        });
      } else if (_updatePlay == true && _isPlaying == false) {
        setState(() {
          _isPlaying = true;
          _isWating = false;
          // _isWaitingController.add(false);
        });
      }
      print("isPlaying: $_isPlaying, Update: $_updatePlay");
      await Future.delayed(const Duration(milliseconds: 500), () async {
        await _realTimeDBService.updateSuccess("updatePlay", false);
      });
    });
    _songStream = FirebaseDatabase.instance.ref().child("Control/ESP_Pub").onValue.listen((event) async {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final update = data['updateSong'];
      setState(() {
        _updateSong = update;
      });

      if (_updateSong == true && _isNext == true) {
        setState(() {
          _isNext = false;
          _song = _nextSong;
          _isWating = false;
          // _isWaitingController.add(false);
        });
        _progressBarController.updateSongDuration(_song.duration);
        _progressBarController.reset();
      } else if (_updateSong == true && _isPre == true) {
        setState(() {
          _isPre = false;
          _song = _nextSong;
          _isWating = false;
          // _isWaitingController.add(false);
        });
        _progressBarController.updateSongDuration(_song.duration);
        _progressBarController.reset();
      } else if (_updateSong == true && _isRepeat == true) {
        await _realTimeDBService.updateOnceControlSignal("finished", false);
        setState(() {
          _isPlaying = true;
          _isWating = false;
          // _isWaitingController.add(false);
        });
      }
      await _realTimeDBService.updateSuccess("updateSong", false);
    });

    _stopStream = FirebaseDatabase.instance.ref().child("Control/ESP_Pub").onValue.listen((event) async {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final update = data['updateStop'];
      setState(() {
        _updateStop = update;
      });

      if (_updateStop == true) {
        setState(() {
          _isWating = false;
        });
        await _realTimeDBService.updateSuccess("updateStop", false);
        if (_isBottomSheetOpen) {
          Navigator.pop(context); // Close the bottom sheet
        }
        Navigator.pop(context); // Close the PlaySongPage
      }
    });
  }

  void deactivate() {
    // TODO: implement deactivate
    _playStream.cancel();
    _songStream.cancel();
    _stopStream.cancel();
    _progressBarController.dispose();
    _progressLostWiFi.dispose();
    super.deactivate();
  }

  @override
  void dispose() {
    _resetControl();
    _isWaitingController.close();
    _isWaitingSubscription.cancel();
    _animationController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 96;
    final radius = (screenWidth - delta) / 2;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          tooltip: 'Navigation menu',
          onPressed: () async {
            await _realTimeDBService.updateOnceControlSignal("stop", true);
            _progressBarController.reset();
            setState(() {
              _isWating = true;
            });
          },
        ),
        title: Text(
          "Đang phát từ danh sách",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.timer_outlined,
              color: Colors.white,
            ),
            tooltip: 'Navigation menu',
            onPressed: showBottomSheet,
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 16),
            Text(_song.album),
            const Text("_ ___ _"),
            const SizedBox(height: 32),
            RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0).animate(_animationController),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: FadeInImage.assetNetwork(
                  placeholder: "assets/itune.png",
                  image: _song.image,
                  width: screenWidth - delta,
                  height: screenWidth - delta,
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      "assets/itune.png",
                      width: screenWidth - delta,
                      height: screenWidth - delta,
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 48, bottom: 16),
              child: SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.share_outlined),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    Column(
                      children: [
                        Text(
                          _song.title,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Theme.of(context).textTheme.bodyMedium!.color,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _song.artist,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Theme.of(context).textTheme.bodyMedium!.color,
                              ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.favorite_outline),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 16),
            //   child: _progressBar(),
            // ),
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 35, right: 35, bottom: 16),
              child: _sliderVolume(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 16),
              child: _mediaButton(),
            )
          ],
        ),
      ),
    );
  }

  _sliderVolume() {
    return Row(
      children: [
        const Text("0"),
        Expanded(
          child: Slider(
            value: _volume,
            max: 10,
            divisions: 10,
            label: _volume.round().toString(),
            onChanged: (double value) {
              setState(() {
                _volume = value;
              });
            },
            onChangeEnd: (double value) async {
              await _realTimeDBService.updateOnceControlSignal("volume", _volume);
            },
          ),
        ),
        const Text("10"),
      ],
    );
  }

  _mediaButton() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          MediaButtonControl(
            function: _setShuffle,
            icon: Icons.shuffle,
            size: 36,
            color: (_isShuffle) ? null : Colors.grey,
          ),
          MediaButtonControl(
            function: _setPreSong,
            icon: Icons.skip_previous_rounded,
            size: 36,
            color: null,
          ),
          _playButton(),
          MediaButtonControl(
            function: _setNextSong,
            icon: Icons.skip_next_rounded,
            size: 36,
            color: null,
          ),
          MediaButtonControl(
            function: _setRepeat,
            icon: Icons.repeat,
            size: 36,
            color: (_isRepeat) ? null : Colors.grey,
          ),
        ],
      ),
    );
  }

  void _playRotationAnim() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward(from: _currentAnimationPosition);
        _animationController.repeat();
      }
    });
  }

  void _pauseRotationAnim() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.stop();
        _currentAnimationPosition = _animationController.value;
      }
    });
  }

  void _resetRotationAnim() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _currentAnimationPosition = 0.0;
        _animationController.value = _currentAnimationPosition;
      }
    });
  }

  _playButton() {
    _progressBarController.setIsPlaying = _isPlaying;
    if (_isPlaying == false) {
      _pauseRotationAnim();
      return MediaButtonControl(
          function: () async {
            await _realTimeDBService.updateOnceControlSignal("play", true);
            //_isWaitingController.add(true);
            _progressLostWiFi.reset();
            setState(() {
              _isWating = true;
            });
          },
          icon: Icons.play_circle_filled_outlined,
          size: 48,
          color: null);
    } else if (_isPlaying == true) {
      _playRotationAnim();
      return MediaButtonControl(
          function: () async {
            await _realTimeDBService.updateOnceControlSignal("play", false);
            //_isWaitingController.add(true);
            _progressLostWiFi.reset();

            setState(() {
              _isWating = true;
            });
          },
          icon: Icons.pause_circle_filled_outlined,
          size: 48,
          color: null);
    }
  }

  void _setNextSong() async {
    print("Index: $_selectedItemIndex");

    if (_isShuffle) {
      var random = Random();
      var newIndex;
      do {
        newIndex = random.nextInt(widget.songs.length);
      } while (newIndex == _selectedItemIndex);
      _selectedItemIndex = newIndex;
    } else {
      ++_selectedItemIndex;
    }
    if (_selectedItemIndex >= widget.songs.length) {
      _selectedItemIndex = _selectedItemIndex % widget.songs.length;
    }

    print("Index: $_selectedItemIndex");
    _nextSong = widget.songs[_selectedItemIndex];

    ControlSignal controlSignal = ControlSignal(
      update: false, // don't care
      finished: false, // don't care
      play: true,
      songID: _selectedItemIndex + 1,
      volume: 0, // don't care
    );
    await _realTimeDBService.updateMultipleControlSignals(controlSignal);
    _resetRotationAnim();

    // Delay calling setState until the current frame is done building
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        _isNext = true;
        _progressLostWiFi.reset();

        //_isWaitingController.add(true);
        setState(() {
          _isPlaying = true;
          _isWating = true;
        });
      }
    });
  }

  void _setPreSong() async {
    print("Index: $_selectedItemIndex");

    if (_isShuffle) {
      var random = Random();
      var newIndex;
      do {
        newIndex = random.nextInt(widget.songs.length);
      } while (newIndex == _selectedItemIndex);
      _selectedItemIndex = newIndex;
    } else {
      --_selectedItemIndex;
    }
    if (_selectedItemIndex < 0) {
      _selectedItemIndex = widget.songs.length - 1;
    }

    print("Index: $_selectedItemIndex");
    _nextSong = widget.songs[_selectedItemIndex];

    ControlSignal controlSignal = ControlSignal(
      update: false, // don't care
      finished: false, // don't care
      play: true,
      songID: _selectedItemIndex + 1,
      volume: 0, // don't care
    );
    await _realTimeDBService.updateMultipleControlSignals(controlSignal);
    _resetRotationAnim();

    // Delay calling setState until the current frame is done building
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        _isPre = true;
        _isPlaying = false;
        // _isWaitingController.add(true);
        _progressLostWiFi.reset();

        setState(() {
          _isPlaying = true;
          _isWating = true;
        });
      }
    });
  }

  void _setShuffle() {
    // Delay calling setState until the current frame is done building
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          _isShuffle = !_isShuffle;
          if (_isRepeat == true && _isShuffle == true) {
            _isRepeat = false;
          }
        });
      }
    });
  }

  void _setRepeat() {
    // Delay calling setState until the current frame is done building
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          _isRepeat = !_isRepeat;
          if (_isRepeat == true && _isShuffle == true) {
            _isShuffle = false;
          }
        });
      }
    });
  }

  void showBottomSheet() {
    setState(() {
      _isBottomSheetOpen = true;
    });
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
          child: Container(
            height: 400,
            color: Colors.black,
            child: TimeNavigator(
              timeController: _timeController,
            ),
          ),
        );
      },
    ).whenComplete(() {
      setState(() {
        _isBottomSheetOpen = false;
      });
    });
  }
}

class MediaButtonControl extends StatefulWidget {
  final Function()? function;
  final IconData icon;
  final double? size;
  final Color? color;

  const MediaButtonControl({
    super.key,
    required this.function,
    required this.icon,
    required this.size,
    required this.color,
  });

  @override
  State<MediaButtonControl> createState() => _MediaButtonControlState();
}

class _MediaButtonControlState extends State<MediaButtonControl> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(widget.icon),
      iconSize: widget.size,
      color: widget.color ?? Theme.of(context).colorScheme.primary,
    );
  }
}
