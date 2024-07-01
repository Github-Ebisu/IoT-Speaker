import 'package:flutter/material.dart';
import 'package:spotifour/ui/home/timer/countdown.dart';
import 'package:spotifour/ui/home/timer/time_controller.dart';
import 'package:spotifour/ui/home/timer/time_picker.dart';

class TimeNavigator extends StatefulWidget {
  final TimeController timeController;

  TimeNavigator({
    super.key,
    required this.timeController,
  });

  @override
  _TimeNavigatorState createState() => _TimeNavigatorState();
}

class _TimeNavigatorState extends State<TimeNavigator> {
  late bool _showTimePicker;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.timeController.state == TimeState.init) {
      _showTimePicker = true;
    } else {
      _showTimePicker = !widget.timeController.timer!.isActive;
    }
  }

  void toggleTimeView() {
    setState(() {
      _showTimePicker = !_showTimePicker;
    });
  }

  @override
  Widget build(BuildContext context) {
    return (_showTimePicker)
        ? CustomTimePicker(
            timeController: widget.timeController, // Pass the timeController
            toggleTimeView: toggleTimeView,
          )
        : CustomCountDown(
            timeController: widget.timeController, // Pass the timeController
            toggleTimeView: toggleTimeView,
          );
  }
}
