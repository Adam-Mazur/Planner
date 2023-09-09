import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:planner/misc/notifications.dart';
import 'package:planner/misc/generate_plan.dart';
import 'package:planner/misc/postpone.dart';
import 'package:planner/misc/get_data.dart';
import 'package:flutter/material.dart';
import 'package:planner/settings.dart';
import 'package:planner/tasks.dart';
import 'misc/colors.dart';
import 'home_page.dart';

void main() async {
  // Getting the data from the disk
  await GetData.start();
  await LocalNotification.init();
  generatePlan();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @pragma("vm:entry-point")
  static Future <void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    if(receivedAction.buttonKeyPressed == "Postpone") {
      // Pushing the MainWidget and removing all pages beneath it
      MyApp.navigatorKey.currentState!.pushReplacementNamed('/notification');
      // Showing postpone Dialog
      await showPostpone(
        MyApp.navigatorKey.currentContext!, 
        [
          ...?GetData.planData[
            DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
            )
          ]
        ]
      );
      // Refreshing the app by poping the current page and pushing it back
      MyApp.navigatorKey.currentState!.popAndPushNamed('/notification');
    }
  }

  @override
  void initState() {
    super.initState();
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: MyApp.navigatorKey,
      routes: {
        '/notification': (context) => const MainWidget()
      },
      title: 'Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: MaterialColor(secondaryColor.value, {
          50: secondaryColor,
          for (int i = 100; i <= 900; i += 100) i: secondaryColor
        }),
      ),
      home: const MainWidget(),
    );
  }
}

class MainWidget extends StatefulWidget {
  const MainWidget({super.key});

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  int pageIndex = 1;

  var pages = const [
    Settings(), 
    HomePage(), 
    Tasks()
  ];

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: pages[pageIndex],

        // Bottom nav bar
        bottomNavigationBar: Container(
          height: 45,
          width: double.infinity,
          decoration: BoxDecoration(
            color: mainColor,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: mainColor,
              border: Border.all(color: lightGrey, width: 0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      pageIndex = 0;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (pageIndex == 0) ? thirdColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(100)
                    ),
                    child: Icon(
                      Icons.settings_rounded, 
                      color: (pageIndex == 0) ? secondaryColor : grey,
                      size: 30,
                    ),
                  )
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      pageIndex = 1;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (pageIndex == 1) ? thirdColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(100)
                    ),
                    child: Icon(
                      Icons.home_rounded, 
                      color: (pageIndex == 1) ? secondaryColor : grey,
                      size: 30,
                    ),
                  )
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      pageIndex = 2;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (pageIndex == 2) ? thirdColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(100)
                    ),
                    child: Icon(
                      Icons.list_rounded, 
                      color: (pageIndex == 2) ? secondaryColor : grey,
                      size: 30,
                    ),
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
