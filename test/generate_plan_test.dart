import 'package:planner/misc/generate_plan.dart';
import 'package:planner/misc/get_data.dart';
import 'package:test/test.dart';

void main () {
  GetData.planData = {};
  generatePlan();

  GetData.planData.forEach(
    (key, value) {
      List<String> data = [];
      for (var i in value) {
        data.add(i.name);
        data.add(i.startTime.toString());
        data.add(i.endTime.toString());
        data.add("\n");
      }
      print("$key:\n ${data.join(" ")}\n");
    },
  );
  
  group("Test group number one - ", 
    () {
      test("Date Times test passed!", 
        () {
          expect(GetData.planData.keys.length, 8);
          var matcher = List.generate(
            8, 
            (index) => DateTime(
              DateTime.now().year, 
              DateTime.now().month, 
              DateTime.now().day
            ).add(Duration(days: index))
          );
          
          for (int i = 0; i < matcher.length; i++) {
            expect(
              GetData.planData.keys.toList()[i],
              matcher[i]
            );
          }
        },
      );

      test("Plans do not repeat test passed!", 
        () {
          for (var i in GetData.planData.values) {
            var names = [for(var j in i) j.name];
            expect(
              names.toSet().toList().length == names.length, 
              true
            );
          }
        },
      );

      test("Plans match the schedule test passed!",
        () {
          for (var i in GetData.planData.values) {
            for (var j in i) {
              var temp1 = GetData.settingsDefaultSchedule.indexWhere(
                (element) => element >= j.endTime.hour * 60 + j.endTime.minute
              );
              var temp2 = GetData.settingsDefaultSchedule.lastIndexWhere(
                (element) => element <= j.startTime.hour * 60 + j.startTime.minute  
              );
              if (!GetData.savedTasks.firstWhere((element) => element.name == j.name).everydayTask) {
                expect(temp2 % 2 == 0, true);
                expect(temp2 + 1, temp1);
              }
            }
          }
        },
      );

      test("Plans don't overlap test passed!", 
        () {
          for (var i in GetData.planData.values) {
            var temp = i;
            temp.sort(
              (a, b) => (a.startTime.hour * 60 + a.startTime.minute) - 
                (b.startTime.hour * 60 + b.startTime.minute)
            );
            for (int i = 0; i < temp.length-1; i++) {
              expect(
                temp[i].endTime.hour*60 + temp[i].endTime.minute <=
                temp[i+1].startTime.hour*60 + temp[i+1].startTime.minute, 
                true
              );
            }
          }
        },
      );

      test("Everyday tasks are correct test passed!", 
        () {
          for (var i in GetData.savedTasks) {
            if(i.everydayTask) {
              for (var j in GetData.planData.values) {
                expect(
                  j.any((element) => element.name == i.name), 
                  true
                );
                expect(
                  j.any((element) => element.startTime == i.everydayTaskTime), 
                  true
                );
              }
            }
          }
        },
      );

      
    },
  );


}