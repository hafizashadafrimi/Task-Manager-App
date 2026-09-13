import 'package:flutter/foundation.dart';

import '../models/note_model.dart';
import '../services/note_storage_service.dart';

class NoteController extends ChangeNotifier {
  NoteController(this._storage);

  final NoteStorageService _storage;

  List<NoteModel> _notes = [];
  String _searchQuery = '';

  List<NoteModel> get notes {
    if (_searchQuery.trim().isEmpty) return _notes;
    final query = _searchQuery.trim().toLowerCase();
    return _notes
        .where((note) => note.title.toLowerCase().contains(query))
        .toList();
  }

  String get searchQuery => _searchQuery;

  Future<void> loadNotes() async {
    _notes = _storage.getAllNotes();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addNote({
    required String title,
    required String description,
  }) async {
    final now = DateTime.now();
    final note = NoteModel(
      id: now.microsecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await _storage.addNote(note);
    await loadNotes();
  }

  Future<void> updateNote({
    required String id,
    required String title,
    required String description,
  }) async {
    final existing = _storage.getNoteById(id);
    if (existing == null) return;

    final updated = existing.copyWith(
      title: title.trim(),
      description: description.trim(),
      updatedAt: DateTime.now(),
    );
    await _storage.updateNote(updated);
    await loadNotes();
  }

  Future<void> deleteNote(String id) async {
    await _storage.deleteNote(id);
    await loadNotes();
  }

  NoteModel? getNoteById(String id) => _storage.getNoteById(id);
}
