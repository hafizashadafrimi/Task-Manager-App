import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_app_assignment/models/note_model.dart';

void main() {
  test('NoteModel serializes and deserializes correctly', () {
    final now = DateTime(2026, 9, 13, 12, 30);
    final note = NoteModel(
      id: '1',
      title: 'Shopping List',
      description: 'Buy milk and eggs',
      createdAt: now,
      updatedAt: now,
    );

    final json = note.toJson();
    final restored = NoteModel.fromJson(json);

    expect(restored.id, note.id);
    expect(restored.title, note.title);
    expect(restored.description, note.description);
    expect(restored.createdAt, note.createdAt);
    expect(restored.updatedAt, note.updatedAt);
  });

  test('NoteModel copyWith updates selected fields', () {
    final now = DateTime(2026, 9, 13);
    final note = NoteModel(
      id: '1',
      title: 'Old Title',
      description: 'Old description',
      createdAt: now,
      updatedAt: now,
    );

    final updated = note.copyWith(
      title: 'New Title',
      updatedAt: DateTime(2026, 9, 14),
    );

    expect(updated.id, note.id);
    expect(updated.title, 'New Title');
    expect(updated.description, note.description);
    expect(updated.updatedAt, DateTime(2026, 9, 14));
  });
}
