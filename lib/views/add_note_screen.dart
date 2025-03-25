import 'package:flutter/material.dart';
import 'package:notewa/core/color_utils.dart';
import '../models/note_model.dart';
import '../services/note_database_services.dart';

class AddNoteScreen extends StatefulWidget {
  final VoidCallback onNoteAdded;
  const AddNoteScreen({super.key, required this.onNoteAdded});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  List<Color> noteColors = notesColors;
  Color selectedColor = Colors.yellow; // Default selected color

  void _addNote() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("title cann't be empty"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // prepare and insert new note
    try {
      // Prepare note data
      final newNote = Note(
        title: _titleController.text,
        content: _contentController.text,
        color: colorToString(selectedColor), // e.g Colors.green to "green"
        dateCreated: DateTime.now(),
        dateUpdated: DateTime.now(),
        dateDeleted: null,
        isDeleted: false,
      );

      // Insert note into database
      final db = NoteDatabase.instance;
      int result = await db.insertNote(newNote);

      if (result > 0) {
        // Successfully inserted
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Note added successfully!'),
              backgroundColor: Colors.greenAccent,
              duration: Duration(seconds: 8),
            ),
          );
        }
      } else {
        // Failed to insert
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add note!'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 8),
            ),
          );
        }
      }
    } catch (e) {
      // Handle any unexpected errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 8),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Title",
                hintStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _contentController,
              style: TextStyle(color: Colors.white),
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "Content",
                hintStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
              ),
            ),
            SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: AlwaysScrollableScrollPhysics(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:
                    noteColors.map((color) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColor = color;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border:
                                selectedColor == color
                                    ? Border.all(color: Colors.white, width: 1)
                                    : null,
                          ),

                          child:
                              selectedColor == color
                                  ? Icon(Icons.check, color: Colors.black)
                                  : SizedBox.shrink(),
                        ),
                      );
                    }).toList(),
              ),
            ),
            SizedBox(height: 56),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                fixedSize: Size(600.0, 50.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              onPressed: () {
                _addNote();
                // Wait for 4 seconds, then navigate back
                Future.delayed(Duration(seconds: 4), () {
                  widget.onNoteAdded(); // load notes in the home screen.
                  if (!context.mounted) return;
                  Navigator.pop(context); // pop the modalbottomsheet
                });
              },
              child: Text(
                "Add",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
