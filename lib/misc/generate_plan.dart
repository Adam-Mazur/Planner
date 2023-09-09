import 'package:planner/main.dart';
import 'package:planner/misc/colors.dart';
import 'package:planner/misc/fonts.dart';
import 'package:planner/misc/notifications.dart';
import 'package:planner/misc/calendar.dart';
import 'package:planner/misc/get_data.dart';
import 'package:flutter/material.dart';
import 'dart:math';

void generatePlan() {
  var todaysDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  ); 

  // Cleaning up statistics
  var tempStats = {...GetData.homePageNumOfMinutes};
  var tempPlan = {...GetData.planData};

  tempPlan.forEach(
    (key, value) {
      if (
        key.isBefore(todaysDate) && 
        key.isAfter(todaysDate.add(const Duration(days: -8)))
        ) 
      {
        int time = value.fold(0, 
          (pV, e) => pV + e.endTime.hour * 60 + e.endTime.minute 
                      - e.startTime.hour * 60 - e.startTime.minute
        );
        tempStats.addAll({key: time});
      }
    }
  );

  tempStats.removeWhere(
    (key, value) => key.isBefore(todaysDate.add(const Duration(days: -7)))
  );

  GetData.homePageNumOfMinutes = tempStats;

  // Deleting completed plans
  tempPlan.removeWhere(
    (key, value) => key.isBefore(todaysDate) 
  );

  List<DateTime> planDates = tempPlan.keys.toList();
  // Sorting dates from first to last
  planDates.sort((a, b) => a.difference(b).inMinutes);
  // The last date for which there is a plan
  DateTime lastDate;
  if(planDates.isNotEmpty){
    lastDate = planDates[planDates.length - 1];
  } else {
    lastDate = todaysDate.add(const Duration(days: -1));
  }


  // Schedule is a list of doubles representing minutes between which
  // tasks can be performed
  List<double> schedule = [...GetData.settingsDefaultSchedule];
  
  List<double> everydayTaskSchedule = [];
  for (var i in GetData.savedTasks) {
    if(i.everydayTask) {
      everydayTaskSchedule.add(
        (i.everydayTaskTime!.hour*60 + i.everydayTaskTime!.minute).toDouble()
      );
      everydayTaskSchedule.add(
        (i.everydayTaskTime!.hour*60 + i.everydayTaskTime!.minute
          + i.duration.inMinutes
        ).toDouble()
      );
    }
  }

  // Updating schedule with data from everydayTaskSchedule 
  for (int i = 0; i < everydayTaskSchedule.length; i+=2) {
    int lowerFirstIndex = schedule.lastIndexWhere(
      (element) => element < everydayTaskSchedule[i]
    );
    int lowerSecondIndex = schedule.lastIndexWhere(
      (element) => element <= everydayTaskSchedule[i+1],
    );
    int upperSecondIndex = schedule.indexWhere(
      (element) => element > everydayTaskSchedule[i+1],
    );

    // Removing boundaries in between
    if (upperSecondIndex != -1 && lowerFirstIndex + 1 != upperSecondIndex) {
      schedule.removeRange(lowerFirstIndex + 1, upperSecondIndex);
    } else if (upperSecondIndex == -1) {
      schedule.removeRange(lowerFirstIndex + 1, schedule.length);
    }

    if(lowerFirstIndex % 2 == 0) {
      schedule.add(everydayTaskSchedule[i]);
    }

    if(lowerSecondIndex % 2 == 0) {
      schedule.add(everydayTaskSchedule[i+1]);
    }

    schedule.sort();
  }

  var tasks = [...GetData.savedTasks];

  // If there are no tasks saved
  if(tasks.isEmpty) {
    GetData.planData = tempPlan;
    return;
  }

  // Filter out the everyday tasks
  for (int i = 0; i < tasks.length; i++) {
    if (tasks[i].everydayTask) {
      tasks.removeAt(i);
    }
  }

  var random = Random(DateTime.now().microsecondsSinceEpoch);

  // Generating a plan for every day after the last day for which there is
  // a plan generated 
  for
  (
    var date = lastDate.add(const Duration(days: 1)); 
    date.isBefore(todaysDate.add(Duration(days: GetData.settingsScheduleInAdvance + 1))); 
    date = date.add(const Duration(days: 1))
  )
  {
    var plan = generateRange(tasks, schedule, random);

    // Add everyday tasks
    for (var i in GetData.savedTasks) {
      if (i.everydayTask) {
        plan.add(
          CalendarData(
            name: i.name,
            startTime: i.everydayTaskTime!,
            endTime: TimeOfDay(
              hour: (i.everydayTaskTime!.hour*60 +
                      i.everydayTaskTime!.minute + i.duration.inMinutes) ~/ 60,
              minute: (i.everydayTaskTime!.hour*60 
                        + i.everydayTaskTime!.minute + i.duration.inMinutes) % 60
            )
          )
        );
      }
    }

    tempPlan.addAll({date: plan});

    // Scheduling the notifications
    for (var i in plan) {
      LocalNotification.schedule(
        DateTime(date.year, date.month, date.day, i.startTime.hour, i.startTime.minute), 
        "Start the new task", 
        i.name
      );
      LocalNotification.schedule(
        DateTime(date.year, date.month, date.day, i.endTime.hour, i.endTime.minute), 
        "End task", 
        i.name
      );
    }

  }

  GetData.planData = tempPlan;

}

List<CalendarData> generateRange(
  List<TaskData> tasks, List<double> schedule, Random random) {
  List<CalendarData> plan = [];
  
  var tasksIndecies = [];
  for (int i = 0; i < tasks.length; i++) {
    for (int j = 0; j < (tasks[i].importance + 1); j++) {
      tasksIndecies.add(i);
    }
  }

  for(int i = 0; i < schedule.length; i+=2) {
    if (tasksIndecies.isEmpty) {
      break;
    }

    final int timeInMinutes = (schedule[i+1] - schedule[i]).toInt();
    List<int> drawnTasks = [];

    int time = timeInMinutes;
    while (time > 0 && tasksIndecies.isNotEmpty) {
      int randomInt = random.nextInt(tasksIndecies.length); 
      int index = tasksIndecies[randomInt];
      drawnTasks.add(index);
      time -= tasks[index].duration.inMinutes;
      tasksIndecies.removeWhere((element) => element == index);
    }

    // Removing the last task if the surplus is too long, 
    // and calculating the scaleFactor
    double scaleFactor;
    // If there is only one task drawn, but its too long
    if (drawnTasks.length == 1 && -time > tasks[drawnTasks.last].duration.inMinutes/2) {
      int removed = drawnTasks.removeLast();
      for (int j = 0; j < (tasks[removed].importance + 1); j++) {
        tasksIndecies.add(removed);
      }
      int? newIndex;
      for (var element in tasksIndecies) {
        int durationInMinutes = tasks[element].duration.inMinutes;
        if (durationInMinutes <= timeInMinutes &&
          (newIndex == null ||  
          durationInMinutes > tasks[newIndex].duration.inMinutes)) 
        {
          newIndex = element;
        }
      }
      if (newIndex != null) {
        tasksIndecies.removeWhere((element) => element == newIndex);
        drawnTasks.add(newIndex);
        scaleFactor = timeInMinutes / tasks[newIndex].duration.inMinutes;
      } else {
        continue;
      }
    } else if(-time > tasks[drawnTasks.last].duration.inMinutes/2) {
      scaleFactor = timeInMinutes / 
        (timeInMinutes - time - tasks[drawnTasks.last].duration.inMinutes);
      int removed = drawnTasks.removeLast();
      for (int j = 0; j < (tasks[removed].importance + 1); j++) {
        tasksIndecies.add(removed);
      }
    } else {
      scaleFactor = timeInMinutes / (timeInMinutes - time);
    }

    int timeIndex = schedule[i].toInt();
    plan.addAll(
      List.generate(
        drawnTasks.length, 
        (index) {
          var task = tasks[drawnTasks[index]];
          TimeOfDay startT = TimeOfDay(
            hour: timeIndex ~/ 60, 
            minute: timeIndex % 60
          );
          timeIndex += ((task.duration.inMinutes * scaleFactor)/5).round() * 5;
          TimeOfDay endT = TimeOfDay(
            hour: timeIndex ~/ 60, 
            minute: timeIndex % 60
          );
          if (index == drawnTasks.length - 1) {
            endT = TimeOfDay(
              hour: schedule[i+1] ~/ 60, 
              minute: schedule[i+1].toInt() % 60
            );
          }
          var temp = CalendarData(
            name: task.name, 
            startTime: startT, 
            endTime: endT,
          );
          return temp;
        }
      )
    );
  }
  return plan;
}

Future<void> refreshPlan({bool dontAskForToday = false}) async {
  bool changeThePlan = true;
  bool changeForToday = true;

  ScaffoldMessenger.of(MyApp.navigatorKey.currentContext!).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 5),
      content: const Text("Change the plan"),
      action: SnackBarAction(
        label: "Yes",
        onPressed: () async {
          if (!dontAskForToday) {
            await showDialog(
              context: MyApp.navigatorKey.currentContext!, 
              builder: (context) => StatefulBuilder(
                builder: (context, setState) => AlertDialog(
                  backgroundColor: mainColor,
                  title: Text("Change the plan", style: subtitleFont),
                  content: const Text("Change the plan for today too?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      }, 
                      child: const Text("Yes")
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          changeForToday = false;
                        });
                        Navigator.pop(context);
                      }, 
                      child: const Text("No")
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          changeThePlan = false;
                        });
                        Navigator.pop(context);
                      }, 
                      child: const Text("Cancel")
                    ),
                  ],
                )
              )
            );
          } else {
            changeForToday = false;
          }
        },
      ), 
    )
  );

  if (changeThePlan && !changeForToday) {
    var tempPlan = {...GetData.planData};
    Map<DateTime, List<CalendarData>> toRemove = {};

    for(var planEntry in tempPlan.entries) {
      var temp = planEntry.key.isAfter(
        DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day
        )
      );
      if (temp) {
        toRemove.addAll({planEntry.key: planEntry.value});
      }
    }
    
    for(var i in toRemove.keys) {
      tempPlan.remove(i);
    }

    GetData.planData = tempPlan;

    for(var j in toRemove.entries) {
      for(int i = 0; i < j.value.length; i++) {
        await LocalNotification.cancelNotification(
          DateTime(
            j.key.year,
            j.key.month,
            j.key.day,
            j.value[i].startTime.hour,
            j.value[i].startTime.minute,
          )
        );
        await LocalNotification.cancelNotification(
          DateTime(
            j.key.year,
            j.key.month,
            j.key.day,
            j.value[i].endTime.hour,
            j.value[i].endTime.minute,
          )
        );
      }
    }
    generatePlan();
  } else if (changeThePlan && changeForToday) {
    GetData.planData = {};
    await LocalNotification.cancelAll();
    generatePlan();
  }
}

Future<void> refreshNotifications() async {
  await LocalNotification.cancelAll();
  // Scheduling the notifications
  GetData.planData.forEach(
    (key, value) async {
      for(var i in value) {
        await LocalNotification.schedule(
          DateTime(key.year, key.month, key.day, i.startTime.hour, i.startTime.minute), 
          "Start the new task", 
          i.name
        );
        await LocalNotification.schedule(
          DateTime(key.year, key.month, key.day, i.endTime.hour, i.endTime.minute), 
          "End task", 
          i.name
        );
      }
    }
  );
}