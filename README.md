# Description
This app is a Flutter app that helps users keep track of their tasks and responsibilities, including hobbies. With the app, users can create, edit, and prioritize tasks related to their hobbies, keep track of their progress, and organize their schedules.

The app also generates a customized schedule based on the user's available time and the time required for each task. This feature helps users manage their time effectively and ensures that they have enough time for their hobbies.

# Screenshots
<p align="left">
  <img src="https://github.com/Adam-Mazur/Planner/blob/main/flutter_01.png" width="400">
  <img src="https://github.com/Adam-Mazur/Planner/blob/main/flutter_03.png" width="400">
  <img src="https://github.com/Adam-Mazur/Planner/blob/main/flutter_04.png" width="400">
  <img src="https://github.com/Adam-Mazur/Planner/blob/main/flutter_02.png" width="400">
</p>

# Tour of the app
Planner automatically generates a schedule for few days in advance (customizable is settings). It ensures that all the tasks are within the default time bounds, and prioritizes the most important ones. Tasks can be repeated every day, or set for one-time completion.

The home page includes a calendar view, a schedule view and the options to modify the plan. The "Postpone task" feature allows users to delay upcoming tasks by a customizable amount of time (maximum time can be set in the settings). The "Modify the plan" feature enables users to delete tasks and add new ones for the current day only. The “Start next task” feature ends current tasks and starts the next one.

The task page allows the user to prioritize tasks based on their importance, edit them, and add new ones. Tasks are sorted from the most important ones, “Must do”, to the “Not much important” ones.

The settings page allows you to change the default time range for which the schedule is automatically generated, to change the number of days to generate the plan in advance, and to change the maximum postponement duration.

Alarm notifications are sent at the beginning and end of every task.

# Libraries used
- [Awesome Notifications](https://pub.dev/packages/awesome_notifications)
- [Drag and drop lists](https://pub.dev/packages/drag_and_drop_lists)
- [Duration picker](https://pub.dev/packages/duration_picker)
