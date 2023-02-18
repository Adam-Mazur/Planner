import 'package:planner/misc/generate_plan.dart';
import 'package:planner/misc/calendar.dart';
import 'package:planner/misc/get_data.dart';
import 'package:planner/misc/colors.dart';
import 'package:planner/misc/fonts.dart';
import 'package:flutter/material.dart';

Future<List<CalendarData>> showPostpone(BuildContext context, List<CalendarData> plan) async {
  int? duration = 10;

  await showDialog(
    context: context, 
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: mainColor,
        title: Text("Choose duration", style: subtitleFont),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Material(
                  borderRadius: BorderRadius.circular(5),
                  color: secondaryColor,
                  child: InkWell(
                    onTap: () {
                      if (duration! > 1) {
                        setState(() {
                          duration = duration! - 1;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(5),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Center(
                        child: Icon(
                          Icons.arrow_drop_down_outlined, 
                          color: mainColor, 
                          size: 20
                        )
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Container(
                  margin: const EdgeInsets.only(bottom: 0, right: 1),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7.5),
                    color: mainColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(1, 4),
                        blurRadius: 4
                      ),
                    ]
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, bottom: 5, top: 5),
                    child: Text(
                      "$duration min",
                      style: regularFont,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Material(
                  borderRadius: BorderRadius.circular(5),
                  color: secondaryColor,
                  child: InkWell(
                    onTap: () {
                      if (duration! < GetData.settingsPostoneDuration) {
                        setState(() {
                          duration = duration! + 1;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(5),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Center(
                        child: Icon(
                          Icons.arrow_drop_up_rounded,
                          color: mainColor, 
                          size: 20
                        )
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                duration = null;
              });
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              textStyle: regularBoldFont
            ), 
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context), 
            style: TextButton.styleFrom(
              textStyle: regularBoldFont
            ), 
            child: const Text('Postpone'),
          ),
        ],
      
      ),
    ),
  );

  if(duration != null) {
    plan.sort(
      (a, b) =>
        (a.endTime.hour * 60 + a.endTime.minute) -
        (b.endTime.hour * 60 + b.endTime.minute)
    );
    int index = plan.indexWhere(
      (element) {
        int time = element.startTime.hour * 60 + element.startTime.minute;
        int currentTime = TimeOfDay.now().hour * 60 + TimeOfDay.now().minute;
        if(time >= currentTime) {
          return true;
        }
        return false;
      }
    );
    // If there are no tasks after this moment, return
    if(index == -1) {
      return plan;
    }

    if(index != 0 && 
      plan[index-1].endTime.hour * 60 + plan[index-1].endTime.minute > 
      TimeOfDay.now().hour * 60 + TimeOfDay.now().minute) {
      plan[index-1] = CalendarData(
        name: plan[index-1].name, 
        startTime: plan[index-1].startTime, 
        endTime: TimeOfDay(
          hour: (plan[index-1].endTime.hour * 60 + plan[index-1].endTime.minute + duration!)~/60, 
          minute: (plan[index-1].endTime.hour * 60 + plan[index-1].endTime.minute + duration!)%60
        )
      );
    }

    int taskDuration = plan[index].endTime.hour * 60 + plan[index].endTime.minute 
                    - plan[index].startTime.hour * 60 - plan[index].startTime.minute;

    if(taskDuration > duration!) {
      var newTime = TimeOfDay(
        hour: (plan[index].startTime.hour * 60 + plan[index].startTime.minute + duration!)~/60, 
        minute: (plan[index].startTime.hour * 60 + plan[index].startTime.minute + duration!)%60
      );
      plan[index] = CalendarData(
        name: plan[index].name, 
        startTime: newTime, 
        endTime: plan[index].endTime
      );
  
    } else {
      var newStartTime = TimeOfDay(
        hour: (plan[index].startTime.hour * 60 + plan[index].startTime.minute + duration!)~/60, 
        minute: (plan[index].startTime.hour * 60 + plan[index].startTime.minute + duration!)%60
      );

      int nextTask = -1;
      if(index != plan.length-1) {
        nextTask = plan[index+1].startTime.hour * 60 + plan[index+1].startTime.minute; 
      }

      TimeOfDay newEndTime;

      if(nextTask == -1 || 
        nextTask>=plan[index].endTime.hour*60+plan[index].endTime.minute+duration!) {
        newEndTime = TimeOfDay(
          hour: (plan[index].endTime.hour * 60 + plan[index].endTime.minute + duration!)~/60, 
          minute: (plan[index].endTime.hour * 60 + plan[index].endTime.minute + duration!)%60
        );
      } else {
        newEndTime = TimeOfDay(
          hour: nextTask ~/ 60, 
          minute: nextTask % 60
        );
      }
      plan[index] = CalendarData(
        name: plan[index].name, 
        startTime: newStartTime, 
        endTime: newEndTime
      );
    }
    var displayDate = DateTime(
      DateTime.now().year, 
      DateTime.now().month, 
      DateTime.now().day
    );

    var temp = {...GetData.planData};
    temp[displayDate] = plan;
    GetData.planData = temp;
    WidgetsFlutterBinding.ensureInitialized();
    refreshNotifications();

  }
  
  return plan;
}