import 'package:flutter/material.dart';

import '../controllers/note_controller.dart';
import '../models/note_model.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_button.dart';

class AddEditNoteScreen extends StatefulWidget {
  const AddEditNoteScreen({
    super.key,
    required this.controller,
    this.note,
  });

  final NoteController controller;
  final NoteModel? note;

  bool get isEditing => note != null;

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.note?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    if (widget.isEditing) {
      await widget.controller.updateNote(
        id: widget.note!.id,
        title: _titleController.text,
        description: _descriptionController.text,
      );
    } else {
      await widget.controller.addNote(
        title: _titleController.text,
        description: _descriptionController.text,
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.softGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Text(
                      widget.isEditing ? 'Edit Note' : 'New Note',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          textCapitalization: TextCapitalization.sentences,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Note title',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: EdgeInsets.zero,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Title is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.purple.withValues(alpha: 0.5),
                                AppColors.cyan.withValues(alpha: 0.5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: TextFormField(
                            controller: _descriptionController,
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.text,
                              height: 1.6,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Start writing your note...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              alignLabelWithHint: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Opacity(
                          opacity: _isSaving ? 0.6 : 1,
                          child: PrimaryButton(
                            label: widget.isEditing ? 'Update Note' : 'Save Note',
                            icon: Icons.check_rounded,
                            onPressed: _isSaving ? () {} : _saveNote,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
