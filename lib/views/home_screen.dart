import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notewa/core/category_constants.dart';
import 'package:notewa/core/routes.dart';
import 'package:notewa/models/note_model.dart';
import 'package:notewa/services/note_database_services.dart';
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
  String? selectedCategory;
  final allCategories = CategoryConstants.predefinedCategories;
  List<String> filteredCategories = [];
  List<Note> matchedNotesCategories = [];
  bool isFilterOn = false;

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
      if (isFilterOn) {
        _filterNotes(filteredCategories); // filter based on categories selected
      } else {
        filteredNotes = notes;
      }
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

      if (!isFilterOn) {
        filteredNotes =
            notes.where((note) {
              return note.title.toLowerCase().contains(query.toLowerCase()) ||
                  note.content!.toLowerCase().contains(query.toLowerCase()) ||
                  note.dateCreated.toIso8601String().toLowerCase().contains(
                    query.toLowerCase(),
                  );
            }).toList();
      } else {
        filteredNotes =
            matchedNotesCategories.where((note) {
              return note.title.toLowerCase().contains(query.toLowerCase()) ||
                  note.content!.toLowerCase().contains(query.toLowerCase()) ||
                  note.dateCreated.toIso8601String().toLowerCase().contains(
                    query.toLowerCase(),
                  );
            }).toList();
      }
    });
  }

  /// Function to handle notes filtering
  void _filterNotes(List selectedCategories) {
    if (selectedCategories.isEmpty) {
      setState(() {
        isFilterOn = false;
      });
      _loadNotes();
    }
    final matches =
        notes.where((note) {
          final category = note.category;
          return selectedCategories.contains(category);
        }).toList();
    setState(() {
      isFilterOn = true;
      filteredNotes = matches;
      matchedNotesCategories = matches;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat(
      'MMMM dd, yyyy',
    ); // format date to July 28, 2025

    // ignore: avoid_print
    print(filteredCategories);
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
                          icon: Icon(
                            filteredCategories.isEmpty
                                ? Icons.filter_alt_outlined
                                : Icons.filter_alt_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return AlertDialog(
                                      backgroundColor: Colors.grey[900],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      alignment: Alignment.topRight,
                                      title: Text(
                                        "Filter Categories",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                      content: SizedBox(
                                        height: 200,
                                        width: 110,
                                        child: ListView.builder(
                                          itemCount: allCategories.length,
                                          itemBuilder: (context, index) {
                                            final category =
                                                allCategories[index];
                                            return CheckboxListTile(
                                              controlAffinity:
                                                  ListTileControlAffinity
                                                      .leading,
                                              title: Text(category),
                                              value: filteredCategories
                                                  .contains(category),
                                              onChanged: (value) {
                                                setState(() {
                                                  if (value == true) {
                                                    filteredCategories.add(
                                                      category,
                                                    );
                                                  } else {
                                                    filteredCategories.remove(
                                                      category,
                                                    );
                                                  }
                                                });
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            filteredCategories.clear();
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _filterNotes(filteredCategories);
                                            Navigator.of(
                                              context,
                                            ).pop(filteredCategories);
                                          },

                                          child: Text(
                                            "Apply Filter",
                                            style: TextStyle(
                                              color: Colors.blueGrey[400],
                                            ),
                                          ),
                                        ),
                                      ],
                                      actionsAlignment:
                                          MainAxisAlignment.spaceBetween,
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                        if (filteredCategories.isNotEmpty)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              constraints: BoxConstraints(
                                minHeight: 14,
                                minWidth: 14,
                              ),
                              child: Center(
                                child: Text(
                                  "${filteredCategories.length}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
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
                                    if (isFilterOn) {
                                      filteredNotes = matchedNotesCategories;
                                    } else {
                                      filteredNotes = List.from(notes);
                                    }
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
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.addNote,
                    arguments: {"callbackFunc": _loadNotes},
                  );
                },
                backgroundColor: Colors.blue.shade200,
                child: Icon(Icons.add, color: Colors.white),
              )
              : null,
    );
  }
}
