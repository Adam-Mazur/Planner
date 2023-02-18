String formatDuration(Duration? duration) {
  if (duration == null) {
    return "";
  }
  String temp = "";
  int inMinutes = duration.inMinutes;
  if (inMinutes >= 24 * 60) {
    temp += "${inMinutes ~/ (24 * 60)}d ";
  }
  if 
  (inMinutes >= 60 &&
    (inMinutes - (inMinutes ~/ (24 * 60)) * 24 * 60) ~/ 60 != 0
  ) {
    temp += "${(inMinutes - (inMinutes ~/ (24 * 60)) * 24 * 60) ~/ 60}h ";
  }
  if 
  (inMinutes - (inMinutes ~/ (24 * 60)) * 24 * 60 -
    ((inMinutes - (inMinutes ~/ (24 * 60)) * 24 * 60) ~/ 60) * 60 != 0
  ) {
    int value = inMinutes - (inMinutes ~/ (24 * 60)) * 24 * 60 -
                ((inMinutes - (inMinutes ~/ (24 * 60)) * 24 * 60) ~/ 60) * 60;
    temp += "${value}min ";
  }
  return temp;
}

Duration fromString(String input) {
  input = input.toLowerCase();

  int? days;
  int? hours;
  int? minutes;

  String buffer = "";
  for (int i = 0; i < input.length; i++) {
    if (buffer.isNotEmpty && input[i] == "d") {
      days = int.parse(buffer.trim());
      buffer = "";
    } else if (buffer.isNotEmpty && input[i] == "h") {
      hours = int.parse(buffer.trim());
      buffer = "";
    } else if
    (
      buffer.isNotEmpty 
      // The character is m
      && input[i] == "m"
      // i is not the last character of input
      &&
      i != input.length - 1
      // The next character is i
      &&
      input[i + 1] == "i"
      // i is not the second to last character
      &&
      i != input.length - 2
      // The second character after i is n
      &&
      input[i + 2] == "n"
    ) {
      minutes = int.parse(buffer.trim());
      buffer = "";
    } else if
    // The character is a number
    (
      !input[i].contains("d") &&
      !input[i].contains("h") &&
      !input[i].contains("m") &&
      !input[i].contains("i") &&
      !input[i].contains("n") &&
      !input[i].contains(" ")
    ) {
      buffer += input[i];
    }
  }
  days ??= 0;
  hours ??= 0;
  minutes ??= 0;

  return Duration(days: days, hours: hours, minutes: minutes);
}
