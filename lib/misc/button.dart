import 'package:planner/misc/fonts.dart';
import 'package:flutter/material.dart';
import 'colors.dart';

class Button extends StatelessWidget {
  const Button(
    {super.key,
    required this.text,
    required this.func,
    required this.isSmall,
    required this.color,
    required this.isEnabled}
  );

  final Function func;
  final String text;
  final bool isEnabled;
  final bool isSmall;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Material(
        borderRadius: (isSmall) 
          ? BorderRadius.circular(7.5) 
          : BorderRadius.circular(15),
        color: (isEnabled) ? color : lightGrey,
        child: (isEnabled)
            ? InkWell(
                borderRadius: (isSmall)
                    ? BorderRadius.circular(7.5)
                    : BorderRadius.circular(15),
                onTap: () => func(),
                child: Padding(
                  padding: (isSmall)
                      ? const EdgeInsets.symmetric(vertical: 7, horizontal: 7.5)
                      : const EdgeInsets.all(10),
                  child: Text(
                    text,
                    style: (isSmall)
                        ? regularBoldFont.copyWith(color: mainColor)
                        : regularFont.copyWith(color: mainColor),
                  ),
                ),
              )
            : Padding(
                padding: (isSmall)
                    ? const EdgeInsets.symmetric(vertical: 7, horizontal: 7.5)
                    : const EdgeInsets.all(10),
                child: Text(
                  text,
                  style: (isSmall)
                      ? regularBoldFont.copyWith(color: mainColor)
                      : regularFont.copyWith(color: mainColor),
                ),
              ),
      ),
    );
  }
}
