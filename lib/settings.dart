import 'package:planner/misc/multislider.dart';
import 'package:planner/misc/get_data.dart';
import 'package:planner/misc/colors.dart';
import 'package:planner/misc/fonts.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> with AutomaticKeepAliveClientMixin {
  // This is preserving the state of this screen
  @override
  bool get wantKeepAlive => true;
  

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Container(
      color: mainColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 25, right: 25, bottom: 10, top: 25),
            child: Text("Default schedule", style: regularFont),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 35, right: 35, top: 10),
            child: MultiSlider(
              divisions: 288,
              max: 1440,
              values: GetData.settingsDefaultSchedule,
              onChanged: (values) {
                // Make sure the schedule is never empty
                if (values.isNotEmpty) {
                  setState(() {
                    GetData.settingsDefaultSchedule = values;
                  });
                }
              },
              color: secondaryColor,
              horizontalPadding: 0,
              height: 45,
              displayDivisions: false,
              addOrRemove: true,
              defaultRange: 100,
              showTooltip: true,
              tooltipBuilder: (value) => TimeOfDay(
                hour: (value != 1440) ? value~/60 : 0, 
                minute: (value%60).toInt(),
              ).format(context),
              tooltipTheme: CustomTooltipData(
                backgroundColor: mainColor,
                textStyle: smallFont,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10, right: 20, left: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                9, 
                (index) {
                  String text = "";
                  if (index*3 > 0 && index*3 < 12) {
                    text = "${index*3}AM";
                  } else if (index*3 == 12) {
                    text = "12PM";
                  } else if (index*3 > 12 && index*3 < 24) {
                    text = "${index*3 - 12}PM";
                  } else if (index*3 == 0 || index*3 == 24) {
                    text = "12AM";
                  }
                  return Text(
                    text,
                    style: verySmallFont,
                  );
                }
              ),
            ),
          ),
          Divider(color: lightGrey),
          Padding(
            padding:
                const EdgeInsets.only(left: 25, right: 25, bottom: 10, top: 10),
            child: Text("Schedule in advance", style: regularFont),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 25, right: 25, bottom: 10, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Material(
                  borderRadius: BorderRadius.circular(5),
                  color: secondaryColor,
                  child: InkWell(
                    onTap: () {
                      if (GetData.settingsScheduleInAdvance >= 1) {
                        setState(() {
                          GetData.settingsScheduleInAdvance -= 1;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(5),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Center(
                          child: Icon(Icons.arrow_drop_down_outlined,
                              color: mainColor, size: 20)),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Container(
                  margin: const EdgeInsets.only(bottom: 6, right: 1),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7.5),
                      color: mainColor,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(1, 4),
                            blurRadius: 4),
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, bottom: 5, top: 5),
                    child: Text(
                      (GetData.settingsScheduleInAdvance == 1) 
                        ? "1 day" 
                        : "${GetData.settingsScheduleInAdvance} days",
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
                      if (GetData.settingsScheduleInAdvance < 100) {
                        setState(() {
                          GetData.settingsScheduleInAdvance += 1;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(5),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Center(
                          child: Icon(Icons.arrow_drop_up_rounded,
                              color: mainColor, size: 20)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: lightGrey),
          Padding(
            padding:
                const EdgeInsets.only(left: 25, right: 25, bottom: 10, top: 10),
            child: Text("Maximum postpone duration", style: regularFont),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 25, right: 25, bottom: 10, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Material(
                  borderRadius: BorderRadius.circular(5),
                  color: secondaryColor,
                  child: InkWell(
                    onTap: () {
                      if (GetData.settingsPostoneDuration > 1) {
                        setState(() {
                          GetData.settingsPostoneDuration -= 1;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(5),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Center(
                          child: Icon(Icons.arrow_drop_down_outlined,
                              color: mainColor, size: 20)),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Container(
                  margin: const EdgeInsets.only(bottom: 6, right: 1),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7.5),
                      color: mainColor,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(1, 4),
                            blurRadius: 4),
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, bottom: 5, top: 5),
                    child: Text(
                      "${GetData.settingsPostoneDuration} min",
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
                      if (GetData.settingsPostoneDuration < 100) {
                        setState(() {
                          GetData.settingsPostoneDuration += 1;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(5),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Center(
                          child: Icon(Icons.arrow_drop_up_rounded,
                              color: mainColor, size: 20)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: lightGrey),
        ],
      ),
    );
  }
}
