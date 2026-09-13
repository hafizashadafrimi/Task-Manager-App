import 'package:hive_flutter/hive_flutter.dart';

import '../models/note_model.dart';

class NoteStorageService {
  static const String _boxName = 'notes_box';
  static const String _notesKey = 'notes';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  Box get _box => Hive.box(_boxName);

  List<NoteModel> getAllNotes() {
    final raw = _box.get(_notesKey, defaultValue: <dynamic>[]) as List;
    return raw
        .map((item) => NoteModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> saveNotes(List<NoteModel> notes) async {
    await _box.put(_notesKey, notes.map((note) => note.toJson()).toList());
  }

  Future<void> addNote(NoteModel note) async {
    final notes = getAllNotes()..add(note);
    await saveNotes(notes);
  }

  Future<void> updateNote(NoteModel note) async {
    final notes = getAllNotes();
    final index = notes.indexWhere((item) => item.id == note.id);
    if (index == -1) return;
    notes[index] = note;
    await saveNotes(notes);
  }

  Future<void> deleteNote(String id) async {
    final notes = getAllNotes()..removeWhere((note) => note.id == id);
    await saveNotes(notes);
  }

  NoteModel? getNoteById(String id) {
    try {
      return getAllNotes().firstWhere((note) => note.id == id);
    } catch (_) {
      return null;
    }
  }
}
