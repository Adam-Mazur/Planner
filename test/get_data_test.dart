import 'package:planner/misc/get_data.dart';
import 'package:planner/misc/calendar.dart';
import 'package:flutter/material.dart';
import 'package:test/test.dart';
import 'dart:async';

void main() {
  group("GetData class - ", 
    () {
      test("first test passed!", 
        () async {
          GetData.settingsScheduleInAdvance = 7;
          GetData.homePageNumOfMinutes = {DateTime(2022, 12, 29): 1};
          GetData.settingsPostoneDuration = 30;
          GetData.settingsDefaultSchedule = [0.1, 0.4, 0.5, 0.6];
          GetData.planData = {
            DateTime(2022): [
              CalendarData(
                name: "Learning Haskell", 
                startTime: const TimeOfDay(hour: 13, minute: 5), 
                endTime:  const TimeOfDay(hour: 14, minute: 5),
              ),
              CalendarData(
                name: "Learning Polish", 
                startTime: const TimeOfDay(hour: 15, minute: 5), 
                endTime:  const TimeOfDay(hour: 16, minute: 50),
              ),
            ],
            DateTime(2022, 12, 5): [
              CalendarData(
                name: "Learning UI Design", 
                startTime: const TimeOfDay(hour: 13, minute: 5), 
                endTime:  const TimeOfDay(hour: 14, minute: 5),
              ),
              CalendarData(
                name: "Learning Dart", 
                startTime: const TimeOfDay(hour: 15, minute: 5), 
                endTime:  const TimeOfDay(hour: 16, minute: 50),
              ),
            ]
          };
          GetData.savedTasks = [
            TaskData(
              name: "Learning Haskell", 
              duration: const Duration(hours: 2, minutes: 30), 
              importance: 1,
              everydayTask: true,
              everydayTaskTime: const TimeOfDay(hour: 11, minute: 0),
              key: UniqueKey(),
            ),
            TaskData(
              name: "Learning Polish", 
              duration: const Duration(hours: 2, minutes: 30), 
              importance: 2,
              key: UniqueKey(),
            ),
            TaskData(
              name: "Learning UI Design", 
              duration: const Duration(hours: 2, minutes: 30), 
              importance: 3,
              everydayTask: true,
              everydayTaskTime: const TimeOfDay(hour: 12, minute: 0),
              key: UniqueKey(),
            ),
            TaskData(
              name: "Learning Dart", 
              duration: const Duration(hours: 2, minutes: 30), 
              importance: 0,
              oneTimeTask: true,
              key: UniqueKey(),
            ),
          ];
          await GetData.writeData();
          
          GetData.settingsScheduleInAdvance = 0;
          GetData.homePageNumOfMinutes = {};
          GetData.settingsPostoneDuration = 0;
          GetData.settingsDefaultSchedule = [0];
          GetData.planData = {
            DateTime(0): [
              CalendarData(
                name: "0", 
                startTime: const TimeOfDay(hour: 0, minute: 0), 
                endTime:  const TimeOfDay(hour: 1, minute: 0),
              ),
              CalendarData(
                name: "0", 
                startTime: const TimeOfDay(hour: 0, minute: 0), 
                endTime:  const TimeOfDay(hour: 1, minute: 0),
              ),
            ],
            DateTime(0): [
              CalendarData(
                name: "0", 
                startTime: const TimeOfDay(hour: 0, minute: 0), 
                endTime:  const TimeOfDay(hour: 1, minute: 0),
              ),
              CalendarData(
                name: "0", 
                startTime: const TimeOfDay(hour: 0, minute: 0), 
                endTime:  const TimeOfDay(hour: 1, minute: 0),
              ),
            ]
          };
          GetData.savedTasks = [
            TaskData(
              name: "0", 
              duration: const Duration(hours: 0, minutes: 0), 
              importance: 0,
              key: UniqueKey(),
            ),
            TaskData(
              name: "0", 
              duration: const Duration(hours: 0, minutes: 0), 
              importance: 0,
              key: UniqueKey(),
            ),
            TaskData(
              name: "0", 
              duration: const Duration(hours: 0, minutes: 0), 
              importance: 0,
              everydayTask: true,
              everydayTaskTime: const TimeOfDay(hour: 0, minute: 0),
              key: UniqueKey(),
            ),
            TaskData(
              name: "0", 
              duration: const Duration(hours: 0, minutes: 0), 
              importance: 0,
              key: UniqueKey(),
            ),
          ];


          await GetData.start();


          expect(GetData.settingsScheduleInAdvance, 7);
          expect(GetData.homePageNumOfMinutes[DateTime(2022, 12, 29)], 1);
          expect(GetData.settingsPostoneDuration, 30);
          expect(GetData.settingsDefaultSchedule, [0.1, 0.4, 0.5, 0.6]);
          expect(GetData.planData.keys.toList(), [DateTime(2022), DateTime(2022, 12, 5)]);
          expect(GetData.planData[DateTime(2022)]![0].name, "Learning Haskell");
          expect(GetData.planData[DateTime(2022)]![0].startTime, const TimeOfDay(hour: 13, minute: 5));
          expect(GetData.planData[DateTime(2022)]![0].endTime, const TimeOfDay(hour: 14, minute: 5));
          expect(GetData.planData[DateTime(2022)]![1].name, "Learning Polish");
          expect(GetData.planData[DateTime(2022)]![1].startTime, const TimeOfDay(hour: 15, minute: 5));
          expect(GetData.planData[DateTime(2022)]![1].endTime, const TimeOfDay(hour: 16, minute: 50));
          expect(GetData.planData[DateTime(2022, 12, 5)]![0].name, "Learning UI Design");
          expect(GetData.planData[DateTime(2022, 12, 5)]![0].startTime, const TimeOfDay(hour: 13, minute: 5));
          expect(GetData.planData[DateTime(2022, 12, 5)]![0].endTime, const TimeOfDay(hour: 14, minute: 5));
          expect(GetData.planData[DateTime(2022, 12, 5)]![1].name, "Learning Dart");
          expect(GetData.planData[DateTime(2022, 12, 5)]![1].startTime, const TimeOfDay(hour: 15, minute: 5));
          expect(GetData.planData[DateTime(2022, 12, 5)]![1].endTime, const TimeOfDay(hour: 16, minute: 50));
          expect(GetData.savedTasks[0].name, "Learning Haskell");
          expect(GetData.savedTasks[0].duration, const Duration(hours: 2, minutes: 30));
          expect(GetData.savedTasks[0].importance, 1);
          expect(GetData.savedTasks[0].everydayTask, true);
          expect(GetData.savedTasks[0].everydayTaskTime, const TimeOfDay(hour: 11, minute: 0));
          expect(GetData.savedTasks[1].name, "Learning Polish");
          expect(GetData.savedTasks[1].duration, const Duration(hours: 2, minutes: 30));
          expect(GetData.savedTasks[1].importance, 2);
          expect(GetData.savedTasks[2].name, "Learning UI Design");
          expect(GetData.savedTasks[2].duration, const Duration(hours: 2, minutes: 30));
          expect(GetData.savedTasks[2].importance, 3);
          expect(GetData.savedTasks[2].everydayTask, true);
          expect(GetData.savedTasks[3].name, "Learning Dart");
          expect(GetData.savedTasks[3].duration, const Duration(hours: 2, minutes: 30));
          expect(GetData.savedTasks[3].importance, 0);
          expect(GetData.savedTasks[3].oneTimeTask, true);


        },
      );
      test("second test passed!", 
        () async {
          GetData.settingsScheduleInAdvance = 8;
          GetData.homePageNumOfMinutes = {DateTime(2023, 1, 1): 2};
          GetData.settingsPostoneDuration = 42;
          GetData.settingsDefaultSchedule = [0.123, 0.42352, 0.54564, 0.63563];
          GetData.planData = {
            DateTime(2022): [
              CalendarData(
                name: "Learning Haskell", 
                startTime: const TimeOfDay(hour: 13, minute: 5), 
                endTime:  const TimeOfDay(hour: 14, minute: 5),
              ),
              CalendarData(
                name: "Learning Polish", 
                startTime: const TimeOfDay(hour: 15, minute: 5), 
                endTime:  const TimeOfDay(hour: 16, minute: 50),
              ),
            ],
            DateTime(2022, 12, 5): [
              CalendarData(
                name: "Learning UI Design", 
                startTime: const TimeOfDay(hour: 13, minute: 5), 
                endTime:  const TimeOfDay(hour: 14, minute: 5),
              ),
              CalendarData(
                name: "Learning Dart", 
                startTime: const TimeOfDay(hour: 15, minute: 5), 
                endTime:  const TimeOfDay(hour: 16, minute: 50),
              ),
            ]
          };
          GetData.savedTasks = [
            TaskData(
              name: "Learning Haskell", 
              duration: const Duration(hours: 2, minutes: 30), 
              importance: 1,
              everydayTask: true,
              everydayTaskTime: const TimeOfDay(hour: 11, minute: 0),
              key: UniqueKey(),
            ),
            TaskData(
              name: "Learning Polish", 
              duration: const Duration(hours: 2, minutes: 30), 
              importance: 2,
              key: UniqueKey(),
            ),
            TaskData(
              name: "Learning UI Design", 
              duration: const Duration(hours: 2, minutes: 30), 
              importance: 3,
              everydayTask: true,
              everydayTaskTime: const TimeOfDay(hour: 12, minute: 0),
              key: UniqueKey(),
            ),
            TaskData(
              name: "Learning Dart", 
              duration: const Duration(hours: 2, minutes: 30), 
              importance: 0,
              oneTimeTask: true,
              key: UniqueKey(),
            ),
          ];
          await GetData.writeData();
          
          GetData.settingsScheduleInAdvance = 0;
          GetData.homePageNumOfMinutes = {};
          GetData.settingsPostoneDuration = 0;
          GetData.settingsDefaultSchedule = [0];
          GetData.planData = {
            DateTime(0): [
              CalendarData(
                name: "0", 
                startTime: const TimeOfDay(hour: 0, minute: 0), 
                endTime:  const TimeOfDay(hour: 1, minute: 0),
              ),
              CalendarData(
                name: "0", 
                startTime: const TimeOfDay(hour: 0, minute: 0), 
                endTime:  const TimeOfDay(hour: 1, minute: 0),
              ),
            ],
            DateTime(0): [
              CalendarData(
                name: "0", 
                startTime: const TimeOfDay(hour: 0, minute: 0), 
                endTime:  const TimeOfDay(hour: 1, minute: 0),
              ),
              CalendarData(
                name: "0", 
                startTime: const TimeOfDay(hour: 0, minute: 0), 
                endTime:  const TimeOfDay(hour: 1, minute: 0),
              ),
            ]
          };
          GetData.savedTasks = [
            TaskData(
              name: "0", 
              duration: const Duration(hours: 0, minutes: 0), 
              importance: 0,
              key: UniqueKey(),
            ),
            TaskData(
              name: "0", 
              duration: const Duration(hours: 0, minutes: 0), 
              importance: 0,
              key: UniqueKey(),
            ),
            TaskData(
              name: "0", 
              duration: const Duration(hours: 0, minutes: 0), 
              importance: 0,
              everydayTask: true,
              everydayTaskTime: const TimeOfDay(hour: 0, minute: 0),
              key: UniqueKey(),
            ),
            TaskData(
              name: "0", 
              duration: const Duration(hours: 0, minutes: 0), 
              importance: 0,
              key: UniqueKey(),
            ),
          ];


          await GetData.start();


          expect(GetData.settingsScheduleInAdvance, 8);
          expect(GetData.homePageNumOfMinutes[DateTime(2023, 1, 1)], 2);
          expect(GetData.settingsPostoneDuration, 42);
          expect(GetData.settingsDefaultSchedule, [0.123, 0.42352, 0.54564, 0.63563]);
          expect(GetData.planData.keys.toList(), [DateTime(2022), DateTime(2022, 12, 5)]);
          expect(GetData.planData[DateTime(2022)]![0].name, "Learning Haskell");
          expect(GetData.planData[DateTime(2022)]![0].startTime, const TimeOfDay(hour: 13, minute: 5));
          expect(GetData.planData[DateTime(2022)]![0].endTime, const TimeOfDay(hour: 14, minute: 5));
          expect(GetData.planData[DateTime(2022)]![1].name, "Learning Polish");
          expect(GetData.planData[DateTime(2022)]![1].startTime, const TimeOfDay(hour: 15, minute: 5));
          expect(GetData.planData[DateTime(2022)]![1].endTime, const TimeOfDay(hour: 16, minute: 50));
          expect(GetData.planData[DateTime(2022, 12, 5)]![0].name, "Learning UI Design");
          expect(GetData.planData[DateTime(2022, 12, 5)]![0].startTime, const TimeOfDay(hour: 13, minute: 5));
          expect(GetData.planData[DateTime(2022, 12, 5)]![0].endTime, const TimeOfDay(hour: 14, minute: 5));
          expect(GetData.planData[DateTime(2022, 12, 5)]![1].name, "Learning Dart");
          expect(GetData.planData[DateTime(2022, 12, 5)]![1].startTime, const TimeOfDay(hour: 15, minute: 5));
          expect(GetData.planData[DateTime(2022, 12, 5)]![1].endTime, const TimeOfDay(hour: 16, minute: 50));
          expect(GetData.savedTasks[0].name, "Learning Haskell");
          expect(GetData.savedTasks[0].duration, const Duration(hours: 2, minutes: 30));
          expect(GetData.savedTasks[0].importance, 1);
          expect(GetData.savedTasks[0].everydayTask, true);
          expect(GetData.savedTasks[0].everydayTaskTime, const TimeOfDay(hour: 11, minute: 0));
          expect(GetData.savedTasks[1].name, "Learning Polish");
          expect(GetData.savedTasks[1].duration, const Duration(hours: 2, minutes: 30));
          expect(GetData.savedTasks[1].importance, 2);
          expect(GetData.savedTasks[2].name, "Learning UI Design");
          expect(GetData.savedTasks[2].duration, const Duration(hours: 2, minutes: 30));
          expect(GetData.savedTasks[2].importance, 3);
          expect(GetData.savedTasks[2].everydayTask, true);
          expect(GetData.savedTasks[3].name, "Learning Dart");
          expect(GetData.savedTasks[3].duration, const Duration(hours: 2, minutes: 30));
          expect(GetData.savedTasks[3].importance, 0);
          expect(GetData.savedTasks[3].oneTimeTask, true);


        },
      );

      test("saving data to the disk test passed!", 
        () async {
          GetData.settingsScheduleInAdvance = 8;
          GetData.homePageNumOfMinutes = {DateTime(2023, 1, 1): 2};
          GetData.settingsPostoneDuration = 42;
          GetData.settingsDefaultSchedule = [0.123, 0.42352, 0.54564, 0.63563];
          GetData.planData = {
            DateTime(2022): [
              CalendarData(
                name: "Learning Haskell", 
                startTime: const TimeOfDay(hour: 13, minute: 5), 
                endTime:  const TimeOfDay(hour: 14, minute: 5),
              ),
              CalendarData(
                name: "Learning Polish", 
                startTime: const TimeOfDay(hour: 15, minute: 5), 
                endTime:  const TimeOfDay(hour: 16, minute: 50),
              ),
            ],
            DateTime(2022, 12, 5): [
              CalendarData(
                name: "Learning UI Design", 
                startTime: const TimeOfDay(hour: 13, minute: 5), 
                endTime:  const TimeOfDay(hour: 14, minute: 5),
              ),
              CalendarData(
                name: "Learning Dart", 
                startTime: const TimeOfDay(hour: 15, minute: 5), 
                endTime:  const TimeOfDay(hour: 16, minute: 50),
              ),
            ]
          };
          GetData.savedTasks = [
            TaskData(
              name: "Learning Haskell", 
              duration: const Duration(hours: 2, minutes: 30), 
              importance: 1,
              everydayTask: true,
              everydayTaskTime: const TimeOfDay(hour: 11, minute: 0),
              key: UniqueKey(),
            ),
            TaskData(
              name: "Learning Polish", 
              duration: const Duration(hours: 2, minutes: 30), 
              importance: 2,
              key: UniqueKey(),
            ),
            TaskData(
              name: "Learning UI Design", 
              duration: const Duration(hours: 2, minutes: 30), 
              importance: 3,
              everydayTask: true,
              everydayTaskTime: const TimeOfDay(hour: 12, minute: 0),
              key: UniqueKey(),
            ),
            TaskData(
              name: "Learning Dart", 
              duration: const Duration(hours: 2, minutes: 30), 
              importance: 0,
              oneTimeTask: true,
              key: UniqueKey(),
            ),
          ];
          await GetData.writeData();
          
        },
      );

      test("changing the data inside the class test passed!", 
        () async {
          await GetData.start();


          GetData.settingsScheduleInAdvance = 9;

          await Future.delayed(const Duration(seconds: 15));

        },
      );

      test("reading data from the disk test passed!", 
        () async {
          await GetData.start();
          
          expect(GetData.settingsScheduleInAdvance, 9);
          expect(GetData.homePageNumOfMinutes[DateTime(2023, 1, 1)], 2);
          expect(GetData.settingsPostoneDuration, 42);
          expect(GetData.settingsDefaultSchedule, [0.123, 0.42352, 0.54564, 0.63563]);
          expect(GetData.planData.keys.toList(), [DateTime(2022), DateTime(2022, 12, 5)]);
          expect(GetData.planData[DateTime(2022)]![0].name, "Learning Haskell");
          expect(GetData.planData[DateTime(2022)]![0].startTime, const TimeOfDay(hour: 13, minute: 5));
          expect(GetData.planData[DateTime(2022)]![0].endTime, const TimeOfDay(hour: 14, minute: 5));
          expect(GetData.planData[DateTime(2022)]![1].name, "Learning Polish");
          expect(GetData.planData[DateTime(2022)]![1].startTime, const TimeOfDay(hour: 15, minute: 5));
          expect(GetData.planData[DateTime(2022)]![1].endTime, const TimeOfDay(hour: 16, minute: 50));
          expect(GetData.planData[DateTime(2022, 12, 5)]![0].name, "Learning UI Design");
          expect(GetData.planData[DateTime(2022, 12, 5)]![0].startTime, const TimeOfDay(hour: 13, minute: 5));
          expect(GetData.planData[DateTime(2022, 12, 5)]![0].endTime, const TimeOfDay(hour: 14, minute: 5));
          expect(GetData.planData[DateTime(2022, 12, 5)]![1].name, "Learning Dart");
          expect(GetData.planData[DateTime(2022, 12, 5)]![1].startTime, const TimeOfDay(hour: 15, minute: 5));
          expect(GetData.planData[DateTime(2022, 12, 5)]![1].endTime, const TimeOfDay(hour: 16, minute: 50));
          expect(GetData.savedTasks[0].name, "Learning Haskell");
          expect(GetData.savedTasks[0].duration, const Duration(hours: 2, minutes: 30));
          expect(GetData.savedTasks[0].importance, 1);
          expect(GetData.savedTasks[0].everydayTask, true);
          expect(GetData.savedTasks[0].everydayTaskTime, const TimeOfDay(hour: 11, minute: 0));
          expect(GetData.savedTasks[1].name, "Learning Polish");
          expect(GetData.savedTasks[1].duration, const Duration(hours: 2, minutes: 30));
          expect(GetData.savedTasks[1].importance, 2);
          expect(GetData.savedTasks[2].name, "Learning UI Design");
          expect(GetData.savedTasks[2].duration, const Duration(hours: 2, minutes: 30));
          expect(GetData.savedTasks[2].importance, 3);
          expect(GetData.savedTasks[2].everydayTask, true);
          expect(GetData.savedTasks[3].name, "Learning Dart");
          expect(GetData.savedTasks[3].duration, const Duration(hours: 2, minutes: 30));
          expect(GetData.savedTasks[3].importance, 0);
          expect(GetData.savedTasks[3].oneTimeTask, true);
        },
      );
    },
  );


}