import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:planner/misc/duration_format.dart';
import 'package:planner/misc/generate_plan.dart';
import 'package:planner/misc/get_data.dart';
import 'package:planner/misc/colors.dart';
import 'package:planner/misc/button.dart';
import 'package:planner/misc/fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:planner/tasks.dart';

class AddTasks extends StatefulWidget {
  const AddTasks(
    {super.key,
    this.data,
    required this.add,
    required this.remove,
    required this.change,
    required this.look,
  });

  final TaskData? data;
  final Function(DragAndDropItem, int) add;
  final Function(int, int) remove;
  final Function(int, int, DragAndDropItem) change;
  final List<int> Function(Key) look; 

  @override
  State<AddTasks> createState() => _AddTasksState();
}

class _AddTasksState extends State<AddTasks> {
  String? name;
  Duration? duration;
  int? importance;
  late bool repeat;
  TimeOfDay? repeatTime;
  late bool once;

  late TextEditingController controller;

  late List<String> groups;

  // A key for validating input into duration TextFormField
  final _durationFormKey = GlobalKey<FormState>();

  // A key for validating input into name TextFormField
  final _nameFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    name = (widget.data != null) ? widget.data!.name : null;
    duration = (widget.data != null) ? widget.data!.duration : null;
    importance = (widget.data != null) ? widget.data!.importance : null;
    repeat =  (widget.data != null) ? widget.data!.everydayTask : false;
    repeatTime = (widget.data != null) ? widget.data!.everydayTaskTime : null;
    once = (widget.data != null) ? widget.data!.oneTimeTask : false;

    groups = [
      "Must do", 
      "Urgent", 
      "Low priority", 
      "Not much important",
    ];

    controller = TextEditingController(text: formatDuration(duration));
  }

  bool checkIfEverydayOverlaps() {
    if (repeat) {
      int startTime = repeatTime!.hour * 60 + repeatTime!.minute; 
      int endTime = startTime + duration!.inMinutes;

      for (var i in GetData.savedTasks) {
        if (i.everydayTask) {
          int start = i.everydayTaskTime!.hour*60 + i.everydayTaskTime!.minute;
          int end = i.everydayTaskTime!.hour*60 + i.everydayTaskTime!.minute +
                      i.duration.inMinutes;
        
          if (startTime >= start && startTime < end && 
              (widget.data == null || i.key != widget.data!.key)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("The repeat time overlaps existing tasks")),
            );
            return true;
          }
          if (endTime > start && endTime <= end && 
              (widget.data == null || i.key != widget.data!.key)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("The repeat time overlaps existing tasks")),
            );
            return true;
          }
        }
      }
    }
    return false;
  }

  bool checkDuplicates() {
    if (widget.data == null && GetData.savedTasks.any((e) => e.name == name)) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("The task already exists")),
      );
      return true;
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
      
        title: (widget.data != null)
          ? Text(
              "Edit a Task",
              style: subtitleFont.copyWith(color: mainColor, fontSize: 18),
            )
          : Text(
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

      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          SizedBox(
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
                if (importance == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Choose the importance")),
                  );
                } else if (repeat && repeatTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Select the time")),
                  );
                } else if (repeat && once) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Repeat everyday and Don't repeat cannot be selected at the same time"
                      ),
                    ),
                  );
                } else if (
                  _durationFormKey.currentState!.validate() &&
                  _nameFormKey.currentState!.validate() && 
                  !checkIfEverydayOverlaps() &&
                  !checkDuplicates()
                  ) {
                  // If The function was called to edit a task
                  if (widget.data != null) {

                    var newData = TaskData(
                      duration: duration!,
                      importance: importance!,
                      key: widget.data!.key,
                      name: name!,
                      everydayTask: repeat,
                      everydayTaskTime: (repeat) ? repeatTime : null,
                      oneTimeTask: once,
                    );

                    if(widget.look(widget.data!.key)[0] == importance) {
                      widget.change(
                        importance!, 
                        widget.look(widget.data!.key)[1], 
                        DragAndDropItem(
                          child: MyListItem(
                            data: newData, 
                            add: widget.add, 
                            remove: widget.remove, 
                            change: widget.change, 
                            look: widget.look,
                          ),
                        )
                      );
                    } else {
                      widget.remove(
                        widget.look(widget.data!.key)[0],
                        widget.look(widget.data!.key)[1],
                      );
                      widget.add(
                        DragAndDropItem(
                          child: MyListItem(
                            data: newData, 
                            add: widget.add, 
                            remove: widget.remove, 
                            change: widget.change, 
                            look: widget.look,
                          ),
                        ),
                        importance!
                      );
                    }

                    int index = GetData.savedTasks.indexWhere(
                      (element) => element.key == widget.data!.key
                    );
                    var temp = [...GetData.savedTasks]; 
                    temp[index] = newData;
                    GetData.savedTasks = temp;
                  
                  // If widget was called to add a task
                  } else {
                    var newData = TaskData(
                      duration: duration!,
                      importance: importance!,
                      key: UniqueKey(),
                      name: name!,
                      everydayTask: repeat,
                      everydayTaskTime: (repeat) ? repeatTime : null,
                      oneTimeTask: once,
                    );

                    widget.add(
                      DragAndDropItem(
                        child: MyListItem(
                          data: newData, 
                          add: widget.add, 
                          remove: widget.remove, 
                          change: widget.change, 
                          look: widget.look,
                        ),
                      ),
                      importance!
                    );

                    var temp = [...GetData.savedTasks]; 
                    temp.add(newData);
                    GetData.savedTasks = temp;

                  }
                  
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: (widget.data != null)
                          ? const Text("Edited a task")
                          : const Text("Added a new task"),
                    ),
                  );

                  // Updating the plan
                  refreshPlan();
                }
              },
              // If The function was called to edit a task
              label: (widget.data != null)
                ? Text(
                    "Edit Task",
                    style: regularBoldFont.copyWith(color: mainColor),
                  )
                : Text(
                    "Add Task",
                    style: regularBoldFont.copyWith(color: mainColor),
                  ),
              // This is so that when there are two FABs the flutter won't throw
              // an exception
              heroTag: null,
            ),
          ),


          // If The function was called to edit a task
          if (widget.data != null) const SizedBox(width: 20),
          if (widget.data != null)
            // The remove button
            SizedBox(
              height: 40,
              width: 125,
              child: FloatingActionButton.extended(
                backgroundColor: Colors.red[600],
                elevation: 0,
                focusElevation: 0,
                hoverElevation: 0,
                disabledElevation: 0,
                highlightElevation: 0,
                onPressed: () {
                  widget.remove(
                    widget.look(widget.data!.key)[0],
                    widget.look(widget.data!.key)[1],
                  );

                  int index = GetData.savedTasks.indexWhere(
                    (element) => element.key == widget.data!.key
                  );
                  var temp = [...GetData.savedTasks];
                  temp.removeAt(index);
                  GetData.savedTasks = temp;
                  
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Removed a task"),
                    ),
                  );

                  // Updating the plan
                  refreshPlan();
                },
                label: Text(
                  "Remove Task",
                  style: regularBoldFont.copyWith(color: mainColor),
                ),
                // This is so that when there are two FABs the flutter won't throw
                // an exception
                heroTag: null,
              ),
            ),

        ],
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
                Text("Importance", style: smallFont),
                const SizedBox(height: 5),
                Container(
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(7.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(1, 4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField(
                    dropdownColor: mainColor,
                    // If the function was called to edit the task the default importance
                    // will be the one passed as a parameter
                    value: importance,
                    hint: Text(
                      "Choose importance",
                      style: regularFont.copyWith(color: Colors.grey[600]),
                    ),
                    items: [
                      for (int i = 0; i < groups.length; i++)
                        DropdownMenuItem(
                          value: groups.length - 1 - i,
                          child: Text(groups[i], style: regularFont),
                        )
                    ],
                    onChanged: (value) {
                      setState(() {
                        importance = value;
                      });
                    },
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                MySwitchTile(
                  versionOne: true,
                  updateState: () {
                    setState(() {
                      repeat = !repeat;
                    });
                  },
                  updateTime: (TimeOfDay? time) {
                    setState(() {
                      repeatTime = time;
                    });
                  },
                  defaultState: repeat,
                  defaultTime: repeatTime,
                ),
                const SizedBox(height: 20),
                MySwitchTile(
                  versionOne: false,
                  updateState: () {
                    setState(() {
                      once = !once;
                    });
                  },
                  defaultState: once,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// This is in seperate class, because the setState function wasn't working
// inside the addTaskScreen function
class MySwitchTile extends StatefulWidget {
  const MySwitchTile(
    {super.key,
    required this.versionOne,
    required this.updateState,
    this.defaultState,
    this.defaultTime,
    this.updateTime}
  );

  final Function updateState;
  final Function? updateTime;
  final bool versionOne;
  final bool? defaultState;
  final TimeOfDay? defaultTime;

  @override
  State<MySwitchTile> createState() => MySwitchTileState();
}

class MySwitchTileState extends State<MySwitchTile> {
  bool state = false;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.defaultState != null && widget.defaultState!) {
      state = true;
    }
    if (widget.versionOne && widget.defaultTime != null) {
      selectedTime = widget.defaultTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeColor: secondaryColor,
      activeTrackColor: thirdColor,
      inactiveTrackColor: lightGrey,
      inactiveThumbColor: mainColor,
      title: ClipRect(
        child: Row(
          children: (widget.versionOne)
              ? [
                  Text("Repeat everyday", style: regularFont),
                  const SizedBox(width: 25),
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
                        widget.updateTime!(selectedTime);
                      },
                      isSmall: false,
                      isEnabled: widget.versionOne && state,
                      color: secondaryColor,
                    ),
                  ),
                ]
              : [
                  Text("Don't repeat (do only once)", style: regularFont),
                ],
        ),
      ),
      value: state,
      onChanged: (value) {
        setState(() {
          state = value;
        });
        widget.updateState();
      },
    );
  }
}
