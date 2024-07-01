import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:spotifour/ui/home/timer/time_controller.dart';

class CustomTimePicker extends StatefulWidget {
  final Function toggleTimeView;
  final TimeController timeController;

  CustomTimePicker({
    super.key,
    required this.timeController,
    required this.toggleTimeView,
  });

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  var hour = 0;
  var minute = 0;
  var second = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    hour = widget.timeController.hours;
    minute = widget.timeController.minutes;
    second = widget.timeController.seconds;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Chọn thời gian: ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, "0")}:${second.toString().padLeft(2, "0")}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              )),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text("Giờ", style: TextStyle(color: Colors.white, fontSize: 20)),
                    const SizedBox(height: 15),
                    NumberPicker(
                      minValue: 0,
                      maxValue: 23,
                      value: hour,
                      zeroPad: true,
                      infiniteLoop: true,
                      itemWidth: 80,
                      itemHeight: 60,
                      onChanged: (value) {
                        setState(() {
                          hour = value;
                        });
                      },
                      textStyle: const TextStyle(color: Colors.grey, fontSize: 20),
                      selectedTextStyle: const TextStyle(color: Colors.white, fontSize: 30),
                      decoration: const BoxDecoration(
                        border: Border(
                            top: BorderSide(
                              color: Colors.white,
                            ),
                            bottom: BorderSide(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 40.0),
                  child: Text(":", style: TextStyle(color: Colors.white, fontSize: 30)),
                ),
                Column(
                  children: [
                    const Text("Phút", style: TextStyle(color: Colors.white, fontSize: 20)),
                    const SizedBox(height: 15),
                    NumberPicker(
                      minValue: 0,
                      maxValue: 59,
                      value: minute,
                      zeroPad: true,
                      infiniteLoop: true,
                      itemWidth: 80,
                      itemHeight: 60,
                      onChanged: (value) {
                        setState(() {
                          minute = value;
                        });
                      },
                      textStyle: const TextStyle(color: Colors.grey, fontSize: 20),
                      selectedTextStyle: const TextStyle(color: Colors.white, fontSize: 30),
                      decoration: const BoxDecoration(
                        border: Border(
                            top: BorderSide(
                              color: Colors.white,
                            ),
                            bottom: BorderSide(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 40.0),
                  child: Text(":", style: TextStyle(color: Colors.white, fontSize: 30)),
                ),
                Column(
                  children: [
                    const Text("Giây", style: TextStyle(color: Colors.white, fontSize: 20)),
                    const SizedBox(height: 15),
                    NumberPicker(
                      minValue: 0,
                      maxValue: 59,
                      value: second,
                      zeroPad: true,
                      infiniteLoop: true,
                      itemWidth: 80,
                      itemHeight: 60,
                      onChanged: (value) {
                        setState(() {
                          second = value;
                        });
                      },
                      textStyle: const TextStyle(color: Colors.grey, fontSize: 20),
                      selectedTextStyle: const TextStyle(color: Colors.white, fontSize: 30),
                      decoration: const BoxDecoration(
                        border: Border(
                            top: BorderSide(
                              color: Colors.white,
                            ),
                            bottom: BorderSide(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text(
              "Bắt đầu",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
            onPressed: () {
              widget.timeController.setDuration(hours: hour, minutes: minute, seconds: second);
              widget.timeController.startTimer();
              widget.toggleTimeView();
            },
          ),
        ],
      ),
    );
  }
}
