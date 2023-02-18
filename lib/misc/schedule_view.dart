import 'package:planner/misc/calendar.dart';
import 'package:planner/misc/colors.dart'; 
import 'package:planner/misc/fonts.dart';
import 'package:flutter/material.dart';

List<Color> colors = [
  const Color.fromARGB(255, 231, 70, 69),
  const Color.fromARGB(255, 251, 119, 86),
  const Color.fromARGB(255, 250, 205, 96),
  const Color.fromARGB(255, 102, 191, 253),
  const Color.fromARGB(255, 26, 192, 198),
];

Widget Function(BuildContext, int) scheduleView(
  {required List<CalendarData> data, 
  required TimeOfDay time,
  bool displayDeleteIcon = false,
  Function(int)? onTapRemove}
) {
  
  // Sorting the data by the startTime, from first to last
  data.sort(
    (a, b) =>
      (a.startTime.hour * 60 + a.startTime.minute) -
      (b.startTime.hour * 60 + b.startTime.minute)
  );

  return (context, index) {
    bool active = time.hour * 60 + time.minute <= 
      data[index].endTime.hour * 60 + data[index].endTime.minute;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // The dot
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: (!displayDeleteIcon)
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              // Make the dot [lightGrey] if the [time] is past the
                              // endTime of the task
                              color: (active)
                              ? colors[(index+data[0].name.length) % colors.length]
                              : lightGrey,
                              borderRadius: BorderRadius.circular(1000),
                            ),
                          )
                        : GestureDetector(
                            onTap: () => onTapRemove!(index),
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.red[700],
                                borderRadius: BorderRadius.circular(1000)
                              ),
                              child: const Center(
                                child: Icon(
                                    Icons.close_rounded,
                                    color: Colors.white,
                                    size: 11,
                                  ),
                              ),
                            ),
                          ),
                    ),
                    // The time
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        "${data[index].startTime.format(context)} - "
                        "${data[index].endTime.format(context)}", 
                        style: (active)
                          ? verySmallFont.copyWith(color: faintGrey)
                          : verySmallFont.copyWith(color: lightGrey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                // The name
                Padding(
                  padding: const EdgeInsets.only(left: 155, right: 5),
                  child: Text(
                    data[index].name,
                    style: (active)
                      ? regularFont.copyWith(color: grey)
                      : regularFont.copyWith(color: lightGrey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]
            ),
          ),
          Divider(height: 0.5, thickness: 0.5, color: lightGrey),
        ],
      ),
    );
  };
}
