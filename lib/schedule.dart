import 'package:duration_picker/duration_picker.dart';
import 'package:planner/misc/duration_format.dart';
import 'package:planner/misc/schedule_view.dart';
import 'package:planner/misc/calendar.dart';
import 'package:planner/misc/colors.dart';
import 'package:planner/misc/button.dart';
import 'package:planner/misc/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class Schedule extends StatefulWidget {
  const Schedule(
    {super.key, 
    required this.plan, 
    required this.callback,
    required this.displayTime}
  );

  final List<CalendarData> plan;
  final void Function(List<CalendarData>) callback;
  final bool displayTime;

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  // This is preserving the state of this screen
  late TimeOfDay currentTime;

  @override
  void initState() {
    super.initState();

    currentTime = TimeOfDay.now();

  }

  @override
  Widget build(BuildContext context) {
    
    // Updating the [currentTime] for the schedule builder
    Timer.periodic(
      const Duration(minutes: 1), 
      (timer) {
        currentTime = TimeOfDay.now();
      }
    );
    
    return Scaffold(
      backgroundColor: mainColor,

      appBar: AppBar(
        // The height of the app bar
        toolbarHeight: 50,
        title: Text(
          "Modify the plan",
          style: subtitleFont.copyWith(color: mainColor, fontSize: 18),
        ),
        elevation: 0,
        iconTheme: IconThemeData(color: mainColor),
        backgroundColor: secondaryColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 40,
            width: 100,
            child: FloatingActionButton.extended(
              backgroundColor: secondaryColor,
              elevation: 0,
              focusElevation: 0,
              hoverElevation: 0,
              disabledElevation: 0,
              highlightElevation: 0,
              onPressed: () {
                widget.callback(widget.plan);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Modified the plan"))
                );
                Navigator.pop(context);
              },
              label: Text(
                "Modify",
                style: regularBoldFont.copyWith(color: mainColor),
              ),
              // This is so that when there are two FABs the flutter won't throw
              // an exception
              heroTag: null,
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            height: 40,
            width: 100,
            child: FloatingActionButton.extended(
              backgroundColor: secondaryColor,
              elevation: 0,
              focusElevation: 0,
              hoverElevation: 0,
              disabledElevation: 0,
              highlightElevation: 0,
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => AddTasks(
                      plan: widget.plan,
                      callback: (p) {
                        setState(() {
                          widget.plan.add(p);
                        });
                      },
                    )
                  )
                );
              },
              label: Text(
                "Add Task",
                style: regularBoldFont.copyWith(color: mainColor),
              ),
              // This is so that when there are two FABs the flutter won't throw
              // an exception
              heroTag: null,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            ListView.builder(
              // Allows the ListView to be put inside column  
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.plan.length,
              itemBuilder: scheduleView(
                data: widget.plan, 
                time: (widget.displayTime) 
                  ? currentTime 
                  : const TimeOfDay(hour: 0, minute: 0),
                displayDeleteIcon: true,
                onTapRemove: (index) {
                  setState(() {
                    widget.plan.removeAt(index);
                  });
                },
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}




class AddTasks extends StatefulWidget {
  const AddTasks({
    super.key, 
    required this.callback,
    required this.plan
  });

  final Function(CalendarData) callback;
  final List<CalendarData> plan;

  @override
  State<AddTasks> createState() => _AddTasksState();
}

class _AddTasksState extends State<AddTasks> {
  String? name;
  Duration? duration;
  TimeOfDay? selectedTime;

  // A key for validating input into duration TextFormField
  final _durationFormKey = GlobalKey<FormState>();

  // A key for validating input into name TextFormField
  final _nameFormKey = GlobalKey<FormState>();

  late TextEditingController controller;
  
  @override
  void initState() {
    super.initState();
    controller =  TextEditingController(text: formatDuration(duration));   
  }

  bool checkIfOverlap() {
    int startTime = selectedTime!.hour * 60 + selectedTime!.minute;
    int endTime = startTime + duration!.inMinutes;

    for(var task in widget.plan) {
      int start = task.startTime.hour * 60 + task.startTime.minute;
      int end = task.endTime.hour * 60 + task.endTime.minute;

      if(startTime >= start && startTime < end) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("The task overlaps with an existing task")),
        );
        return true;
      } 
      if(endTime > start && endTime <= end) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("The task overlaps with an existing task")),
        );
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,

      // This makes sure that the screen isn't messed up when the keyboard extends
      resizeToAvoidBottomInset: false,

      appBar: AppBar(
        // The height of the app bar
        toolbarHeight: 50,
      
        title: Text(
          "Add a Task",
          style: subtitleFont.copyWith(color: mainColor, fontSize: 18),
        ),
      
        elevation: 0,
        iconTheme: IconThemeData(color: mainColor),
        backgroundColor: secondaryColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
      ),

      floatingActionButton: SizedBox(
        height: 40,
        width: 100,
        child: FloatingActionButton.extended(
          elevation: 0,
          focusElevation: 0,
          hoverElevation: 0,
          disabledElevation: 0,
          highlightElevation: 0,
          backgroundColor: secondaryColor,
          onPressed: () {
            if(selectedTime == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Select the time"))
              );
            } else if(
              _nameFormKey.currentState!.validate() &&
              _durationFormKey.currentState!.validate() && 
              !checkIfOverlap()
            ) {
              int temp = selectedTime!.hour * 60 + selectedTime!.minute + duration!.inMinutes; 
              widget.callback(
                CalendarData(
                  name: name!, 
                  startTime: selectedTime!, 
                  endTime: TimeOfDay(
                    hour: temp ~/ 60,
                    minute: temp % 60
                  )
                )
              );
              Navigator.pop(context);
            }
          },
          label: Text(
            "Add Task",
            style: regularBoldFont.copyWith(color: mainColor),
          ),
          // This is so that when there are two FABs the flutter won't throw
          // an exception
          heroTag: null,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // The Stack is used to unfocus the screen when the user taps on the
      // background
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: GestureDetector(
              onTap: () {
                // Unfocusing the screen when the user taps on the background
                primaryFocus!.unfocus(disposition: UnfocusDisposition.scope);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Name", style: smallFont),
                Form(
                  key: _nameFormKey,
                  child: TextFormField(
                    controller: TextEditingController(text: name),
                    style: regularFont,
                    cursorColor: secondaryColor,
                    decoration: InputDecoration(
                      // This removes the padding
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 5),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: grey),
                      ),
                    ),
                    onChanged: (String input) {
                      name = input;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter the name";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Duration", style: smallFont),
                          Form(
                            key: _durationFormKey,
                            child: TextFormField(
                              controller: controller,
                              style: regularFont,
                              cursorColor: secondaryColor,
                              decoration: InputDecoration(
                                // This removes the padding
                                isDense: true,
                                hintText: "0d 0h 0min",
                                hintStyle:
                                    regularFont.copyWith(color: Colors.grey[600]),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                border: UnderlineInputBorder(
                                    borderSide: BorderSide(color: grey)),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: grey)),
                              ),
                              // Allowing the user to only type the letters: d,h,m,i,n
                              // and numbers
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(
                                  RegExp(r"""[a-ce-gj-lo-zA-CE-GJ-LO-Z~`!@#$%^&*()_+{}|:"<>?\-=[\]\\;',./]"""),
                                ),
                              ],
                              onChanged: (value) {
                                duration = fromString(value);
                              },
                              validator: (value) {
                                var regexMin = RegExp(
                                  r"min",
                                  caseSensitive: false,
                                );
                                var regexHour = RegExp(
                                  r"h",
                                  caseSensitive: false,
                                );
                                var regexDay = RegExp(
                                  r"d",
                                  caseSensitive: false,
                                );
                                if (value == null || value.isEmpty) {
                                  return "Please enter the duration";
                                }
                                if (regexMin.allMatches(value).length > 1) {
                                  return "The number of minutes is repeating!";
                                }
                                if (regexHour.allMatches(value).length > 1) {
                                  return "The number of hours is repeating!";
                                }
                                if (regexDay.allMatches(value).length > 1) {
                                  return "The number of days is repeating!";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Duration picker
                    GestureDetector(
                      onTap: () async {
                        var temp = await showDurationPicker(
                          context: context,
                          initialTime: duration ?? const Duration(minutes: 0),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                        );
                        if (temp != null) {
                          duration = temp;
                          controller.text = formatDuration(duration);
                        }
                      },
                      child: Icon(
                        Icons.arrow_drop_down_circle_rounded,
                        color: secondaryColor, size: 38,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text("Start time", style: smallFont),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: Button(
                        text: (selectedTime == null)
                            ? "Select time"
                            : selectedTime!.format(context),
                        func: () async {
                          TimeOfDay? temp = await showTimePicker(
                            initialTime: (selectedTime == null)
                                ? TimeOfDay.now()
                                : selectedTime!,
                            context: context,
                          );
                          setState(() {
                            if (temp != null) {
                              selectedTime = temp;
                            }
                          });
                        },
                        isSmall: false,
                        isEnabled: true,
                        color: secondaryColor,
                      ),
                    ),
                  ],
                ),
              ]
            )
          )
        ]
      )

    );
  }
}