import 'package:planner/misc/schedule_view.dart';
import 'package:planner/misc/generate_plan.dart';
import 'package:planner/misc/postpone.dart';
import 'package:planner/misc/get_data.dart';
import 'package:planner/misc/calendar.dart';
import 'package:planner/misc/button.dart';
import 'package:planner/misc/fonts.dart';
import 'package:flutter/material.dart';
import 'package:planner/schedule.dart';
import 'misc/colors.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.postponeOnStart = false});

  final bool postponeOnStart;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  late String greetingText;
  bool calendarElseSchedule = true;
  late TimeOfDay currentTime;
  bool disposeTime = false;
  List<CalendarData> plan = GetData.planData[
    DateTime(
      DateTime.now().year, 
      DateTime.now().month, 
      DateTime.now().day
    )
  ] ?? [];
  DateTime displayDate = DateTime(
    DateTime.now().year, 
    DateTime.now().month, 
    DateTime.now().day
  );
  int selectedButton = 0;
  late int numOfHours;

  // This is preserving the state of this screen
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    int hour = TimeOfDay.now().hour;

    if (hour < 12) {
      greetingText = "Good Morning";
    } else if (hour >= 12 && hour < 18) {
      greetingText = "Good Afternoon";
    } else {
      greetingText = "Good Evening";
    }

    currentTime = TimeOfDay.now();

    numOfHours = GetData.homePageNumOfMinutes.values.fold(0, (pV, e) => pV + e) ~/ 60;

    if(widget.postponeOnStart) {
      postpone();
    }

  }
  
  // Disposing the timer, this solves a bug in which the timer was still running
  // even when the widget was not in the widget tree, and flutter was throwing
  // an exception
  @override
  void dispose() {
    super.dispose();
    disposeTime = true;
  }

  void postpone() async {
    setState(() { 
      displayDate = DateTime(
        DateTime.now().year, 
        DateTime.now().month, 
        DateTime.now().day
      );
      plan = GetData.planData[displayDate] ?? [];
      selectedButton = 0;
    });

    var tempPlan = await showPostpone(context, plan);
    setState(() {
      plan = tempPlan;
    });

  }

  void startNext() {
    setState(() { 
      displayDate = DateTime(
        DateTime.now().year, 
        DateTime.now().month, 
        DateTime.now().day
      );
      plan = GetData.planData[displayDate] ?? [];
      selectedButton = 0;
    });

    setState(() {
      plan.sort(
        (a, b) =>
          (a.endTime.hour * 60 + a.endTime.minute) -
          (b.endTime.hour * 60 + b.endTime.minute)
      );
    });

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
      return;
    }

    if(index != 0) {
      if(plan[index-1].endTime.hour * 60 + plan[index-1].endTime.minute > 
        TimeOfDay.now().hour * 60 + TimeOfDay.now().minute) {
        setState(() {
          plan[index-1] = CalendarData(
            name: plan[index-1].name, 
            startTime: plan[index-1].startTime, 
            endTime: TimeOfDay.now()
          );
        });
      }
    }

    setState(() {
      plan[index] = CalendarData(
        name: plan[index].name, 
        startTime: TimeOfDay.now(), 
        endTime: plan[index].endTime
      );
    });

    var temp = {...GetData.planData};
    temp[displayDate] = plan;
    GetData.planData = temp;
    refreshNotifications();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Updating the [currentTime] for the schedule builder
    Timer.periodic(
      const Duration(minutes: 1), 
      (timer) {
        if(!disposeTime) {
          setState(() {
            currentTime = TimeOfDay.now();

            int hour = TimeOfDay.now().hour;
            if (hour < 12) {
              greetingText = "Good Morning";
            } else if (hour >= 12 && hour < 18) {
              greetingText = "Good Afternoon";
            } else {
              greetingText = "Good Evening";
            }
          });
        } else {
          timer.cancel();
        }
      }
    );

    return Container(
      color: mainColor,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            // From Figma
            expandedHeight: 295,
            backgroundColor: mainColor,
            // This is so that the title of FlexibleSpaceBar alsways stays on the screen
            pinned: true,
            collapsedHeight: 64,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              // This is so that the background scrolls under the title
              collapseMode: CollapseMode.pin,
              background: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: double.infinity,
                  height: 231,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  decoration: BoxDecoration(
                    color: thirdColor,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(greetingText, style: bigFont),
                          SizedBox(
                            width: 225,
                            child: Text(
                              "You've spend $numOfHours hours doing tasks last week",
                              style: subtitleFont,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: [
                          Button(
                            text: "Modify the plan",
                            func: () {
                              Navigator.push(
                                context, 
                                MaterialPageRoute(
                                  builder: (context) => Schedule(
                                    plan: [...plan],
                                    displayTime: displayDate == DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month,
                                      DateTime.now().day,
                                    ),
                                    callback: (p) {
                                      setState(() {
                                        plan = p;
                                      });
                                      var tempPlan = {...GetData.planData};
                                      tempPlan[displayDate] = p;
                                      GetData.planData = tempPlan;
                                      refreshNotifications();
                                    },
                                  ),
                                ),
                              );
                            },
                            isSmall: false,
                            isEnabled: true,
                            color: secondaryColor,
                          ),
                          Button(
                            text: "Postpone task",
                            func: postpone,
                            isSmall: false,
                            isEnabled: true,
                            color: secondaryColor,
                          ),
                          Button(
                            text: "Start next task",
                            func: startNext,
                            isSmall: false,
                            isEnabled: true,
                            color: secondaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              centerTitle: false,
              titlePadding: EdgeInsets.zero,
              expandedTitleScale: 1,
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Button(
                          text: (calendarElseSchedule) 
                          ? "Schedule"
                          : "Calendar",
                          func: () {
                            setState(() {
                              calendarElseSchedule = !calendarElseSchedule;
                            });
                          },
                          isSmall: true,
                          isEnabled: true,
                          color: secondaryColor,
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 225,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: (GetData.planData.isNotEmpty)
                                ? List.generate(
                                  (GetData.planData.length) * 2 - 1, 
                                  (index) {
                                    var time = DateTime.now().add(Duration(days: (index+1)~/2));
                                    if(index % 2 == 0){
                                      return DateButton(
                                        selected: selectedButton == index, 
                                        date: "${time.day}/${time.month}",
                                        onTap: () {
                                          setState(() { 
                                            plan = GetData.planData[
                                              DateTime(
                                                time.year,
                                                time.month,
                                                time.day,
                                              )
                                            ] ?? [];
                                            displayDate = DateTime(
                                              time.year,
                                              time.month,
                                              time.day,
                                            );
                                            selectedButton = index;
                                          });
                                        },
                                      );
                                    } else {
                                      return const SizedBox(width: 10);
                                    }
                                  }
                                )
                                : [DateButton(
                                  selected: true, 
                                  date: "${DateTime.now().day}/${DateTime.now().month}", 
                                  onTap: () {}
                                )],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 0.5,
                    color: lightGrey,
                    thickness: 0.5,
                  ),
                ],
              ),
            ),
          ),
          if (calendarElseSchedule) 
          Calendar(
            // Passing [UniqueKey] because it wasn't updating 
            key: UniqueKey(),
            data: plan,
            displayTimeIndicator: displayDate == DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
            ),
          ),
          if (!calendarElseSchedule)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              scheduleView(
                data: plan,
                time: (displayDate == DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                )) 
                ? currentTime
                : const TimeOfDay(hour: 0, minute: 0),
              ),
              childCount: plan.length
            ),
          ),
        ],
      ),
    );
  }

}


class DateButton extends StatefulWidget {
  const DateButton({
    super.key, 
    required this.selected, 
    required this.date,
    required this.onTap,
  });

  final bool selected;
  final String date;
  final Function() onTap;

  @override
  State<DateButton> createState() => _DateButtonState();
}

class _DateButtonState extends State<DateButton> {
  bool tapped = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        setState(() {
          tapped = true;
        });
      },
      onPointerUp: (event) {
        setState(() {
          tapped = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 6, right: 1),
          width: 50,
          height: 25,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7.5),
            color: (widget.selected) ? secondaryColor : mainColor,
            boxShadow: tapped 
             ? []
             : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(1, 4),
                  blurRadius: 4,
                ),
              ],
          ),
          child: Center(
            child: Text(
              widget.date,
              style: (widget.selected) 
                ? regularFont.copyWith(color: mainColor) 
                : regularFont,
            ),
          ),
        ),
      ),
    );
  }
}
