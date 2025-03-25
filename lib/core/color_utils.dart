import 'package:flutter/material.dart';

List<Color> notesColors = [
    Colors.yellow,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.blue,
    Colors.pink,
    Colors.purple,
    Colors.white,
  ];

// Convert Color to String
String colorToString(Color color) {
  Map<Color, String> colorMap = {
    Colors.red: "red",
    Colors.green: "green",
    Colors.blue: "blue",
    Colors.yellow: "yellow",
    Colors.pink: "pink",
    Colors.purple: "purple",
    Colors.white: "white",
    Colors.black: "black",
    Colors.orange: "orange",
  };

  return colorMap[color] ?? "yellow"; // Default to white if not found
}

// Convert String to Color
Color stringToColor(String colorName) {
  Map<String, Color> colorMap = {
    "red": Colors.red,
    "green": Colors.green,
    "blue": Colors.blue,
    "yellow": Colors.yellow,
    "pink": Colors.pink,
    "purple": Colors.purple,
    "white": Colors.white,
    "black": Colors.black,
  };

  return colorMap[colorName] ?? Colors.white; // Default to white if not found
}