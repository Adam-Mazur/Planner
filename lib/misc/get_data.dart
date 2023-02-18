import 'package:planner/misc/duration_format.dart';
import 'package:path_provider/path_provider.dart';
import 'package:planner/misc/calendar.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';


// Defining the data type of the plan data
typedef PlanData = Map<DateTime, List<CalendarData>>;    

// A class for handling file operations, and retriving data from the disk
abstract class GetData{

  // The data
  static List<double> _settingsDefaultSchedule = [900, 1260];
  static int _settingsScheduleInAdvance = 7;
  static int _settingsPostoneDuration = 30;
  static PlanData _planData = {};
  static Map<DateTime, int> _homePageNumOfMinutes = {};
  static List<TaskData> _savedTasks = [];

  // A variable that controls the updating of the data
  static bool _toUpdate = false;


  // Getter for the instance variables
  static List<double> get settingsDefaultSchedule => _settingsDefaultSchedule;
  static int get settingsScheduleInAdvance => _settingsScheduleInAdvance;
  static int get settingsPostoneDuration => _settingsPostoneDuration;
  static PlanData get planData => _planData;
  static Map<DateTime, int> get homePageNumOfMinutes => _homePageNumOfMinutes;
  static List<TaskData> get savedTasks => _savedTasks;


  // Setters for the instance variables
  static set settingsDefaultSchedule(List<double> value) {
    _toUpdate = true;
    _settingsDefaultSchedule = value;
  }
  static set settingsScheduleInAdvance(int value) {
    _toUpdate = true;
    _settingsScheduleInAdvance = value;
  }
  static set settingsPostoneDuration(int value) {
    _toUpdate = true;
    _settingsPostoneDuration = value;
  }
  static set planData(PlanData value) {
    _toUpdate = true;
    _planData = value;
  }
  static set homePageNumOfMinutes(Map<DateTime, int> value) {
    _toUpdate = true;
    _homePageNumOfMinutes = value;
  }
  static set savedTasks(List<TaskData> value) {
    _toUpdate = true;
    _savedTasks = value;
  }


  // Getting the path from the path_provider package
  static Future<String> get _localPath async {
    WidgetsFlutterBinding.ensureInitialized();
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  // Getting the file with the data
  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/Planner.txt');
  }


  static Future<void> writeData() async {
    final file = await _localFile;

    file.writeAsString(
      jsonEncode(
        {
          "_settingsDefaultSchedule": _settingsDefaultSchedule,
          "_settingsScheduleInAdvance": _settingsScheduleInAdvance,
          "_settingsPostoneDuration": _settingsPostoneDuration,
          "_planData": _planData.map(
            (key, value) => MapEntry(
              key.toString(),
              value.map(
                (e) => {
                  "name": e.name, 
                  "startTime": "${e.startTime.hour}:${e.startTime.minute}",
                  "endTime": "${e.endTime.hour}:${e.endTime.minute}",
                }
              ).toList()
            )
          ),
          "_homePageNumOfMinutes": _homePageNumOfMinutes.map(
            (key, value) => MapEntry(key.toString(), value)
          ),
          "_savedTasks": _savedTasks.map(
            (e) => {
              "name": e.name,
              "duration": formatDuration(e.duration),
              "importance": e.importance,
              "everydayTask": e.everydayTask,
              "everydayTaskTime": (e.everydayTaskTime != null) 
                ? "${e.everydayTaskTime!.hour}:${e.everydayTaskTime!.minute}"
                : null,
              "oneTimeTask": e.oneTimeTask,
            }
          ).toList()
        }
      ),
      flush: true,
    );

    _toUpdate = false;
  }

  // Initialize the data
  static Future<void> start() async {

    final file = await _localFile;

    if(await file.exists()) {
      // Read the file
      Object contents = await file.readAsString();

      contents = jsonDecode(contents as String);

      // Casting the [contents] to a Map, because [jsonDecode] funtion returns 
      // a JSON Object as a Map
      _settingsDefaultSchedule = List<double>.from((contents as Map)["_settingsDefaultSchedule"]);
      _settingsScheduleInAdvance = contents["_settingsScheduleInAdvance"];
      _settingsPostoneDuration = contents["_settingsPostoneDuration"];

      // Getting the plan data in two steps: first getting the data as strings,
      // and then converting it to [CalendarData]
      Map<String, List<dynamic>> tempPlanData = 
          Map<String, List<dynamic>>.from(contents["_planData"]);
      
      _planData = {};
      tempPlanData.forEach(
        (key, value) {
          List<CalendarData> temp = [];
          for (var i in value){
            String name = i["name"]!;
            TimeOfDay startTime = TimeOfDay(
              hour: int.parse(i["startTime"]!.split(":")[0]),
              minute: int.parse(i["startTime"]!.split(":")[1]),
            );
            TimeOfDay endTime = TimeOfDay(
              hour: int.parse(i["endTime"]!.split(":")[0]),
              minute: int.parse(i["endTime"]!.split(":")[1]),
            );
            temp.add(
              CalendarData(
                name: name, 
                startTime: startTime, 
                endTime: endTime,
              )
            );
          }

          _planData.addAll({
            DateTime.parse(key):
            temp,
          });
        }
      );

      Map<String, int> tempNumOfMinutes = 
                        Map<String, int>.from(contents["_homePageNumOfMinutes"]);

      _homePageNumOfMinutes = {};
      tempNumOfMinutes.forEach(
        (key, value) {
          _homePageNumOfMinutes.addAll({
            DateTime.parse(key):
            value
          });
        }
      );

      // Getting the [_savedTasks] in two steps: first getting the data as strings,
      // and then converting it to [TaskData]
      List<Map<dynamic, dynamic>> tempSavedTasks = 
          List<Map<dynamic, dynamic>>.from(contents["_savedTasks"]);

      _savedTasks = [];
      for (var element in tempSavedTasks) {
        _savedTasks.add(
          TaskData(
            name: element["name"] as String, 
            duration: fromString(element["duration"] as String) , 
            importance: element["importance"] as int,
            everydayTask: element["everydayTask"] as bool,
            everydayTaskTime: (element["everydayTaskTime"] != null) 
              ? TimeOfDay(
                hour: int.parse((element["everydayTaskTime"] as String).split(":")[0]),
                minute: int.parse((element["everydayTaskTime"] as String).split(":")[1]),
              )
              : null,
            oneTimeTask: element["oneTimeTask"] as bool,
            key: UniqueKey(),
          )
        );
      }
    }

    // Asynchronously checking every 0.5 seconds if the data is to be updated
    Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) {
        if(_toUpdate){
          writeData();
        }    
      },
    );
  }
}

// A class for managing task data
class TaskData{
  late final String name;
  late final Duration duration;
  late final int importance;
  late final bool everydayTask;
  late final TimeOfDay? everydayTaskTime;
  late final bool oneTimeTask;
  late final Key key;

  TaskData({
    required this.name,
    required this.duration,
    required this.importance,
    this.everydayTask = false,
    this.everydayTaskTime,
    this.oneTimeTask = false,
    required this.key,
  }) : assert(everydayTask && everydayTaskTime != null ||
              !everydayTask && everydayTaskTime == null),
       assert(!(everydayTask && oneTimeTask));

}