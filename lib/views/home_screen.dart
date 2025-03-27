import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notewa/core/routes.dart';
import 'package:notewa/models/note_model.dart';
import 'package:notewa/services/note_database_services.dart';
import 'package:notewa/views/add_note_screen.dart';
import 'package:notewa/widgets/custom_note_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  bool searchClicked = false;
  bool isTapped = false;
  bool isSearching = false;

  // Test Data before creating sqlite database entries.
  // List<Map<String, String>> notes = [
  //   {"title": "Flutter Tips", "content": "Avoid calling setState unnecessarily.", "date":"2025-03-21","color": "purple"},
  //   {"title": "Flutter Developer", "content": "I am a Flutter Developer.", "date":"2025-03-21", "color": "green"},
  //   {"title": "Holy Developer",
  //   "content": "Far from it, I just started the flutter thing but meenh the shit is fvking fun. Can you imaging the other day I was just sitting down and boom an idea popped up, huuuh!",
  //   "date":"2025-02-21", "color": "white"
  //   },
  //   {"title": "Noise in my Head",
  //   "content": "Gibberish, No no nonono The drag between good and evil; an unending battle till thy kingdom com. But we're caught up inbetween the battle, poor shibarish balish kalush, kush. No bank, no bambam, no kinkin, no gaga mando kika,Can you imaging the other day I was just sitting down and boom an idea popped up, huuuh!",
  //   "date":"2025-02-24",
  //   "color": "pink"
  //   },
  //   {"title": "Drag of the Season",
  //   "content": "Gibberish, No no nonono The drag between good and evil; an unending battle till thy kingdom com. But we're caught up inbetween the battle, poor shibarish balish kalush, kush. No bank, no bambam, no kinkin, no gaga mando kika,Can you imaging the other day I was just sitting down and boom an idea popped up, huuuh!",
  //   "date":"2025-01-21",
  //   "color": "orange"
  //   },
  //   {"title": "Damn good Dev",
  //   "content": "Gibberish, No no nonono The drag between good and evil; an unending battle till thy kingdom com. But we're caught up inbetween the battle, poor shibarish balish kalush, kush. No bank, no bambam, no kinkin, no gaga mando kika,Can you imaging the other day I was just sitting down and boom an idea popped up, huuuh!",
  //   "date":"2024-11-21",
  //   "color": "red"
  //   },
  // ];

  List<Note> notes = [];
  List<Note> filteredNotes = [];
  final db = NoteDatabase.instance;

  @override
  void initState() {
    super.initState();
    // filteredNotes = List.from(notes);
    _loadNotes();
  }

  /// Function to load notes
  void _loadNotes() async {
    List<Note> loadedNotes = await db.getNotes();
    setState(() {
      notes = loadedNotes;
      filteredNotes = notes;
    });
  }

  /// Function to delete note
  void _deleteNote(int id) async {
    int result = await db.softDeleteNote(id);

    if (result > 0) {
      // Successfully inserted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('deleted successfully!'),
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
            content: Text('Failed to delete note!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 8),
          ),
        );
      }
    }
  }

  /// Function to show delete popup
  Future<void> _showDeletePopUp(int id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          // uncomment this if need for dailog icon
          // icon: CircleAvatar(
          //   backgroundColor: Colors.redAccent,
          //   radius: 24,
          //   child: Icon(Icons.warning_amber_rounded,color: Colors.white,),
          // ),
          content: const Text(
            "Do you want to delete note?",
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                _deleteNote(id);
                Navigator.of(context).pop();
                _loadNotes();
              },
              child: const Text("Ok", style: TextStyle(color: Colors.blue)),
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
        );
      },
    );
  }

  /// Function to handle search of notes
  void _searchNotes(String query) {
    setState(() {
      isSearching = query.isNotEmpty;

      filteredNotes =
          notes.where((note) {
            return note.title.toLowerCase().contains(query.toLowerCase()) ||
                note.content!.toLowerCase().contains(query.toLowerCase()) ||
                note.dateCreated.toIso8601String().toLowerCase().contains(
                  query.toLowerCase(),
                );
          }).toList();
    });
  }

  /// Function to show modal for add note screen
  void _showAddNoteBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => FractionallySizedBox(
            heightFactor: 0.65,
            child: AddNoteScreen(onNoteAdded: _loadNotes),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat(
      'MMMM dd, yyyy',
    ); // format date to July 28, 2025
    return Scaffold(
      backgroundColor: Colors.black,
      appBar:
          searchClicked
              ? AppBar(
                title: Text(
                  "Search",
                  style: TextStyle(fontSize: 28, color: Colors.white),
                ),
                backgroundColor: Colors.black,
              )
              : AppBar(
                title: const Text(
                  'Notes',
                  style: TextStyle(fontSize: 28, color: Colors.white),
                ),
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
                          icon: const Icon(
                            Icons.search_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () {
                            setState(() {
                              searchClicked = true;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            searchClicked
                ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    onChanged: _searchNotes,
                    onTap: () {
                      setState(() {
                        isTapped = true;
                      });
                    },
                    decoration: InputDecoration(
                      suffixIcon:
                          isTapped
                              ? IconButton(
                                onPressed: () {
                                  setState(() {
                                    searchClicked = false;
                                    isTapped = false;
                                    isSearching = false;
                                    searchController.clear();
                                    filteredNotes = List.from(notes);
                                  });
                                  FocusScope.of(context).unfocus();
                                },
                                icon: Icon(
                                  Icons.close_outlined,
                                  color: Colors.grey,
                                ),
                              )
                              : Icon(Icons.search, color: Colors.pink),
                      hintText: "Search notes...",
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.pink),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                )
                : SizedBox.shrink(),
            SizedBox(height: 18.0),
            filteredNotes.isEmpty
                ? Center(
                  child: Text(
                    "There are no notes now.",
                    style: TextStyle(color: Colors.white),
                  ),
                )
                : Expanded(
                  child: SingleChildScrollView(
                    child: ListView.builder(
                      itemCount: filteredNotes.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final note = filteredNotes[index];
                        final String noteColor = note.color!;
                        final DateTime dateString = DateTime.parse(
                          note.dateCreated.toIso8601String(),
                        );
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.editNote,
                              arguments: {
                                "note": note.toMap(),
                                "callbackFunc": _loadNotes,
                              },
                            );
                          },
                          child: CustomNoteCard(
                            title: note.title,
                            content: note.content!,
                            date: dateFormatter.format(dateString),
                            color:
                                noteColor == "purple"
                                    ? Colors.purple
                                    : noteColor == "green"
                                    ? Colors.green
                                    : noteColor == "yellow"
                                    ? Colors.yellow
                                    : noteColor == "pink"
                                    ? Colors.pink
                                    : noteColor == "red"
                                    ? Colors.red
                                    : noteColor == "orange"
                                    ? Colors.orange
                                    : noteColor == "blue"
                                    ? Colors.blue
                                    : Colors.white,
                            onDelete: () => _showDeletePopUp(note.id!),
                          ),
                        );
                      },
                    ),
                  ),
                ),
          ],
        ),
      ),
      floatingActionButton:
          !isSearching
              ? FloatingActionButton(
                onPressed: _showAddNoteBottomSheet,
                backgroundColor: Colors.blue.shade200,
                child: Icon(Icons.add, color: Colors.white),
              )
              : null,
    );
  }
}
