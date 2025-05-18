import 'package:flutter/material.dart';
import 'package:notewa/core/color_utils.dart';
import 'package:notewa/views/add_note_screen.dart';
import 'package:notewa/views/splash_screen.dart';

// import '../views/add_note_screen.dart';
import '../views/edit_note_screen.dart';
import '../views/home_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String addNote = '/add-note';
  static const String editNote = '/edit-note';
  static const String splashScreen = '/splash-screen';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashScreen:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case addNote:
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          final callbackFunc = args['callbackFunc'];
          return MaterialPageRoute(
            builder: (_) => AddNoteScreen(onNoteAdded: callbackFunc),
          );
        }
        return _errorRoute();
      case editNote:
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          final note = args['note'];
          final callbackFunc = args['callbackFunc'];
          return MaterialPageRoute(
            builder:
                (_) => EditNoteScreen(
                  id: note['id'],
                  title: note['title'] as String,
                  content: note['content'],
                  initialColor: stringToColor(
                    note['color'],
                  ), // e.g "green" to Colors.green
                  onNoteEdited: callbackFunc,
                ),
          );
        }
        return _errorRoute();
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(body: Center(child: Text('Page not found'))),
    );
  }
}
