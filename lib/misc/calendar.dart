import 'package:planner/misc/colors.dart';
import 'package:planner/misc/fonts.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class Calendar extends StatefulWidget {
  const Calendar(
    {super.key,
    this.hourInterval = 50,
    required this.data,
    required this.displayTimeIndicator,
    }
  );

  /// The space between te hour interval in the calendar view
  final double hourInterval;

  final List<CalendarData> data;

  final bool displayTimeIndicator;

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {

  late final int firstHour;
  late final int lastHour;
  late double timeInPix;
  late final double widgetHeight;
  final List<Widget> timesAsWidgets = [];
  final List<Widget> horizontalLines = [];
  final List<Widget> tasks = [];

  final List<Color> colors = [
    const Color.fromARGB(255, 231, 70, 69),
    const Color.fromARGB(255, 251, 119, 86),
    const Color.fromARGB(255, 250, 205, 96),
    const Color.fromARGB(255, 102, 191, 253),
    const Color.fromARGB(255, 26, 192, 198),
  ];

  bool disposeTimer = false;

  @override
  void initState() {
    super.initState();

    // Sorting the data by the endTime, from first to last
    widget.data.sort(
      (a, b) =>
        (a.endTime.hour * 60 + a.endTime.minute) -
        (b.endTime.hour * 60 + b.endTime.minute)
    );


    late final TimeOfDay lastTime;
    if(widget.data.isNotEmpty){
      lastTime = widget.data[widget.data.length - 1].endTime;
    } else {
      // If there is not plan assign 18:00 as last time by default 
      lastTime = const TimeOfDay(hour: 18, minute: 0);
    }

    // Sorting the data by the startTime, from first to last
    widget.data.sort(
      (a, b) =>
        (a.startTime.hour * 60 + a.startTime.minute) -
        (b.startTime.hour * 60 + b.startTime.minute)
    );

    late final TimeOfDay firstTime;
    if (widget.data.isNotEmpty){
      firstTime = widget.data[0].startTime;
    } else {
      firstTime = const TimeOfDay(hour: 8, minute: 0);
    }

    // If the first tasks minute field is non zero then the first displayed 
    // hour will be its hour field, otherwise it will be the one before
    if (firstTime.minute != 0) {
      firstHour = firstTime.hour;
    } else {
      // If there is not plan assign 8:00 as first time by default 
      firstHour = firstTime.hour - 1;
    }

    // The last displayed hour will be the next one after the last tasks
    // hour field
    lastHour = lastTime.hour + 1;

    final int numberOfHorizontalLines = (lastHour - firstHour) + 1;

    final List<String> timesAsStrings = [];

    // Generating times as Strings
    for (int i = firstHour; i <= lastHour; i++) {
      if (i > 0 && i < 12) {
        timesAsStrings.add("$i AM");
      } else if (i == 12) {
        timesAsStrings.add("12 PM");
      } else if (i > 12 && i < 24) {
        timesAsStrings.add("${i - 12} PM");
      } else if (i == 24) {
        timesAsStrings.add("12 AM");
      }
    }

    // Generating times as widgets, every time text is followed by a SizedBox, 
    // except the last one
    for (int i = 0; i < timesAsStrings.length - 1; i++){
      timesAsWidgets.addAll([
        Padding(
          padding: const EdgeInsets.all(5),
          child: Text(
            timesAsStrings[i],
            style: verySmallFont.copyWith(color: faintGrey),
          ),
        ),
        SizedBox(height: widget.hourInterval - 25),
      ]);
    }

    timesAsWidgets.add(
      Padding(
        padding: const EdgeInsets.all(5),
        child: Text(
          timesAsStrings[timesAsStrings.length - 1],
          style: verySmallFont.copyWith(color: faintGrey),
        ),
      ),
    );

    // Generating horizontal lines as widgets, every line is followed by a SizedBox,
    // except the last one
    for (int i = 0; i < numberOfHorizontalLines - 1; i++) {
      horizontalLines.addAll([
        Divider(
          height: 0.5,
          thickness: 0.5,
          color: lightGrey,
          indent: 55,
          endIndent: 10,
        ),
        SizedBox(height: widget.hourInterval - 0.5),
      ]);
    }

    horizontalLines.add(
      Divider(
        height: 0.5,
        thickness: 0.5,
        color: lightGrey,
        indent: 55,
        endIndent: 10,
      ),
    );

    timeInPix = (TimeOfDay.now().hour * 60 + TimeOfDay.now().minute) 
      / 60 * widget.hourInterval - firstHour * widget.hourInterval;

    // Generating tasks as widgets
    for (int i = 0; i < widget.data.length; i++) {
      var startInPixs = (widget.data[i].startTime.hour * 60 +
                        widget.data[i].startTime.minute) / 60 * widget.hourInterval;
      
      var endInPixs = (widget.data[i].endTime.hour * 60 +
                      widget.data[i].endTime.minute) / 60 * widget.hourInterval;
      
      bool active = timeInPix + firstHour * widget.hourInterval <= 
                      (widget.data[i].endTime.hour * 60 + widget.data[i].endTime.minute)
                      / 60 * widget.hourInterval || !widget.displayTimeIndicator;
      tasks.add(
        Positioned(
          left: 60,
          top:  startInPixs - firstHour * widget.hourInterval + 12 + 5,
          bottom: lastHour * widget.hourInterval - endInPixs + 12 + 5,
          right: 10,
          child: Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: (active)
              ? colors[(i+widget.data[0].name.length) % colors.length]
              : lightGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Column(
                children: [
                  const Spacer(),
                  Text(
                    widget.data[i].name,
                    style: regularFont.copyWith(color: mainColor),
                    overflow: TextOverflow.visible,
                  ),
                  const Spacer(flex: 10),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // The height of the whole widget
    widgetHeight = 12 + widget.hourInterval * (numberOfHorizontalLines - 1) + 13 + 2 * 5;

  }

  // Disposing the timer, this solves a bug in which the timer was still running
  // even when the widget was not in the widget tree, and flutter was throwing
  // an exception
  @override
  void dispose() {
    super.dispose();
    disposeTimer = true;
  }


  @override
  Widget build(BuildContext context) {

    if(widget.displayTimeIndicator){
      // Updating the time indicator
      Timer.periodic(
        const Duration(minutes: 1),
        (timer) {
          if(!disposeTimer) {
            setState(() {
              timeInPix = (TimeOfDay.now().hour * 60 + TimeOfDay.now().minute) 
                / 60 * widget.hourInterval - firstHour * widget.hourInterval;
            });
          } else {
            timer.cancel();
          }
        }
      );
    }
    
    // This allows the Calendar to be used inside CustomScrollView
    return SliverToBoxAdapter(
      child: SizedBox(
        height: widgetHeight,
        child: Stack(
          children: [
            // The times
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 5),
                    ...timesAsWidgets,
                    const SizedBox(height: 5),
                  ],
                ),
                // From Figma
                const SizedBox(width: 305)
              ],
            ),

            // Horizontal lines
            Column(
              children: [
                const SizedBox(height: 12 + 5),
                ...horizontalLines,
                const SizedBox(height: 5),
              ],
            ),

            // The vertical line
            Row(
              children: [
                const SizedBox(width: 60),
                Container(
                  color: lightGrey,
                  height: widgetHeight,
                  width: 0.5,
                ),
              ],
            ),

            // Tasks
            ...tasks,              
              
            // Time indicator
            if(widget.displayTimeIndicator)
            Positioned(
              top: timeInPix + 12 + 5 - 5,
              height: 10,
              left: 55,
              width: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            if(widget.displayTimeIndicator)
            Positioned(
              top: timeInPix + 12 + 5 - 0.5,
              height: 1,
              left: 60,
              right: 10,
              child: Divider(
                height: 1,
                thickness: 1,
                color: secondaryColor,
              ),
            ),

          ],
        ),
      ),
    );
  }


}

class CalendarData {
  CalendarData({
    required this.name,
    required this.startTime,
    required this.endTime,
  })  : assert(endTime.hour * 60 + endTime.minute >
            startTime.hour * 60 + startTime.minute),
        assert(name.isNotEmpty);

  final String name;

  final TimeOfDay startTime;

  final TimeOfDay endTime;
}
