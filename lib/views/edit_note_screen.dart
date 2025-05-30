import 'package:flutter/material.dart';
import 'package:notewa/core/category_constants.dart';
import 'package:notewa/core/color_utils.dart';
import 'package:notewa/services/note_database_services.dart';

class EditNoteScreen extends StatefulWidget {
  final int id;
  final String title;
  final String content;
  final Color initialColor;
  final String category;
  final VoidCallback? onNoteEdited;

  const EditNoteScreen({
    super.key,
    required this.id,
    required this.title,
    required this.content,
    required this.initialColor,
    required this.category,
    this.onNoteEdited,
  });

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late Color selectedColor;
  bool _isNoteSaved = false;
  late String selectedCategory;

  List<Color> noteColors = notesColors;
  final allCategories = CategoryConstants.predefinedCategories;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _contentController = TextEditingController(text: widget.content);
    selectedColor = widget.initialColor;
    selectedCategory = widget.category;
  }

  // update note
  void _updateNote({bool autoSave = false}) async {
    if (_titleController.text.isEmpty) return;

    final db = NoteDatabase.instance;
    int result = await db.updateNote(
      id: widget.id,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      color: colorToString(selectedColor),
      category: selectedCategory,
    );

    if (result > 0) {
      // Successfully updated
      if (mounted && !autoSave) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved successfully!'),
            backgroundColor: Colors.grey.shade800,
            duration: Duration(seconds: 4),
          ),
        );
      }
      setState(() {
        _isNoteSaved = true;
      });
    } else {
      // Failed to insert
      if (mounted && !autoSave) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 8),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          if (!_isNoteSaved) {
            _updateNote(autoSave: true);
            widget.onNoteEdited!();
          }
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text("Edit Note", style: TextStyle(color: Colors.white)),
          actions: [
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    margin: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isNoteSaved
                          ? Icons.check_circle_outline_rounded
                          : Icons.check,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      // update note
                      _updateNote();
                      widget
                          .onNoteEdited!(); // reload notes in the home screen. To do: handle this in WillPopScope logic
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: false,
                      isDense: true,
                      menuMaxHeight: 200,
                      menuWidth: 110,
                      value: selectedCategory,
                      items:
                          allCategories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedCategory = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _titleController,
                  onChanged: (value) {
                    setState(() {
                      _isNoteSaved = false;
                    });
                  },
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
                  onChanged: (value) {
                    setState(() {
                      _isNoteSaved = false;
                    });
                  },
                  style: TextStyle(color: Colors.white),
                  maxLines: 14,
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
                SizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      selectedColor == color
                                          ? Colors.white
                                          : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child:
                                  selectedColor == color
                                      ? Icon(
                                        Icons.check,
                                        color: Colors.black,
                                        size: 20,
                                      )
                                      : null,
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
