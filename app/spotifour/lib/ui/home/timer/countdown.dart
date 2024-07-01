import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spotifour/ui/home/timer/time_controller.dart';

class CustomCountDown extends StatefulWidget {
  const CustomCountDown({
    super.key,
    required this.timeController,
    required this.toggleTimeView,
    this.textStyle,
    this.labelTextStyle,
  });

  final TimeController timeController;
  final Function toggleTimeView;
  final TextStyle? textStyle;
  final TextStyle? labelTextStyle;

  @override
  State<CustomCountDown> createState() => _CustomCountDownState();
}

class _CustomCountDownState extends State<CustomCountDown> {
  bool isRunning = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isRunning = widget.timeController.timer!.isActive;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var textStyle = widget.textStyle ?? Theme.of(context).textTheme.headlineLarge!;
    var labelTextStyle = widget.labelTextStyle ?? Theme.of(context).textTheme.bodyMedium!;

    return StreamBuilder<Duration>(
      stream: widget.timeController.progressStream,
      initialData: widget.timeController.currentDuration,
      builder: (context, snapshot) {
        final currentDuration = snapshot.data ?? Duration.zero;

        if (currentDuration <= Duration.zero) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.toggleTimeView();
          });
        }

        final hours = DefaultTextStyle(
          style: textStyle,
          child: Text(currentDuration.inHours.toString().padLeft(2, '0')),
        );

        final minutes = DefaultTextStyle(
          style: textStyle,
          child: Text(currentDuration.inMinutes.remainder(60).toString().padLeft(2, '0')),
        );

        final seconds = DefaultTextStyle(
          style: textStyle,
          child: Text(currentDuration.inSeconds.remainder(60).toString().padLeft(2, '0')),
        );

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressCountDown(
              currentDuration,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildTimeColumn(hours, "Giờ", labelTextStyle),
                  const SizedBox(width: 16),
                  buildTimeColumn(minutes, "Phút", labelTextStyle),
                  const SizedBox(width: 16),
                  buildTimeColumn(seconds, "Giây", labelTextStyle),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  child: const Text(
                    "Thoát",
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  onPressed: () {
                    widget.timeController.stopTimer();
                    widget.toggleTimeView();
                    widget.timeController.state = TimeState.reset;
                  },
                ),
                const SizedBox(width: 50),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  child: Text(
                    (isRunning) ? "Tạm dừng" : "Tiếp tục",
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  onPressed: () {
                    if (widget.timeController.timer!.isActive) {
                      widget.timeController.stopTimer();
                      widget.timeController.state = TimeState.stop;
                    } else {
                      widget.timeController.startTimer();
                      widget.timeController.state = TimeState.run;
                    }
                    setState(() {
                      isRunning = widget.timeController.timer!.isActive;
                    });
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget buildTimeColumn(Widget timeWidget, String label, TextStyle labelTextStyle) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(colors: [
            Color(0xFFA5F5A5),
            Color(0xFFA8F6E5),
          ]).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: timeWidget,
          ),
        ),
        DefaultTextStyle(style: labelTextStyle, child: Text(label, style: const TextStyle(color: Colors.white))),
      ],
    );
  }

  Widget CircularProgressCountDown(Duration currentDuration, Widget child) {
    final totalDuration = widget.timeController.totalDuration;
    return Center(
      child: SizedBox(
        width: 250,
        height: 250,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: (totalDuration.inSeconds != 0) ? 1 - (currentDuration.inSeconds / totalDuration.inSeconds) : 0,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              strokeWidth: 8,
              backgroundColor: Colors.greenAccent,
            ),
            Center(child: child),
          ],
        ),
      ),
    );
  }
}
