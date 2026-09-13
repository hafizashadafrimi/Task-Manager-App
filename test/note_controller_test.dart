import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:task_manager_app_assignment/controllers/note_controller.dart';
import 'package:task_manager_app_assignment/services/note_storage_service.dart';

void main() {
  late NoteStorageService storage;
  late NoteController controller;

  setUp(() async {
    Hive.init('test_notes');
    await Hive.openBox('notes_box');
    storage = NoteStorageService();
    await storage.saveNotes([]);
    controller = NoteController(storage);
  });

  tearDown(() async {
    await Hive.box('notes_box').clear();
    await Hive.close();
  });

  test('addNote stores note and loadNotes retrieves it', () async {
    await controller.addNote(
      title: 'Meeting Notes',
      description: 'Discuss project timeline',
    );

    expect(controller.notes, hasLength(1));
    expect(controller.notes.first.title, 'Meeting Notes');
  });

  test('updateNote changes existing note', () async {
    await controller.addNote(title: 'Draft', description: 'Initial text');
    final id = controller.notes.first.id;

    await controller.updateNote(
      id: id,
      title: 'Final Draft',
      description: 'Updated text',
    );

    expect(controller.notes.first.title, 'Final Draft');
    expect(controller.notes.first.description, 'Updated text');
  });

  test('deleteNote removes note from list', () async {
    await controller.addNote(title: 'Temp', description: 'To delete');
    final id = controller.notes.first.id;

    await controller.deleteNote(id);

    expect(controller.notes, isEmpty);
  });

  test('search filters notes by title', () async {
    await controller.addNote(title: 'Flutter Tips', description: 'Widgets');
    await controller.addNote(title: 'Dart Basics', description: 'Syntax');

    controller.setSearchQuery('flutter');

    expect(controller.notes, hasLength(1));
    expect(controller.notes.first.title, 'Flutter Tips');
  });
}
