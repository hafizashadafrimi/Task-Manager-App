import 'package:flutter/material.dart';

import '../controllers/note_controller.dart';
import '../services/note_storage_service.dart';
import '../theme/app_colors.dart';
import '../widgets/note_card.dart';
import 'add_edit_note_screen.dart';
import 'note_details_screen.dart';

class NotesHomeScreen extends StatefulWidget {
  const NotesHomeScreen({super.key});

  @override
  State<NotesHomeScreen> createState() => _NotesHomeScreenState();
}

class _NotesHomeScreenState extends State<NotesHomeScreen> {
  late final NoteController _controller;
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = NoteController(NoteStorageService());
    _controller.loadNotes();
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _openAddNote() async {
    final saved = await Navigator.of(context).push<bool>(
      _buildRoute(AddEditNoteScreen(controller: _controller)),
    );
    if (saved == true && mounted) {
      _showSnack('Note created successfully');
    }
  }

  Future<void> _openNoteDetails(String noteId) async {
    await Navigator.of(context).push(
      _buildRoute(
        NoteDetailsScreen(controller: _controller, noteId: noteId),
      ),
    );
  }

  PageRouteBuilder<T> _buildRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<bool> _confirmDelete(String noteId, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _controller.deleteNote(noteId);
      if (mounted) _showSnack('Note deleted');
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final notes = _controller.notes;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.softGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Notes',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${notes.length} ${notes.length == 1 ? 'note' : 'notes'} saved',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.purpleGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.purple.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: _openAddNote,
                        icon: const Icon(Icons.add, color: Colors.white),
                        tooltip: 'Add note',
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.purple.withValues(
                          alpha: _searchFocus.hasFocus ? 0.15 : 0.06,
                        ),
                        blurRadius: _searchFocus.hasFocus ? 16 : 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: _searchFocus.hasFocus
                          ? AppColors.purple.withValues(alpha: 0.4)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    onChanged: (value) {
                      _controller.setSearchQuery(value);
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by title...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                _controller.setSearchQuery('');
                                setState(() {});
                              },
                              icon: const Icon(Icons.close_rounded),
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: notes.isEmpty
                    ? _EmptyState(
                        isSearching: _controller.searchQuery.isNotEmpty,
                        onAdd: _openAddNote,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: Duration(milliseconds: 300 + (index * 60)),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 16 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: NoteCard(
                              note: note,
                              index: index,
                              onTap: () => _openNoteDetails(note.id),
                              onConfirmDelete: () => _confirmDelete(note.id, note.title),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddNote,
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text('New Note'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.isSearching,
    required this.onAdd,
  });

  final bool isSearching;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                isSearching ? Icons.search_off_rounded : Icons.note_add_outlined,
                size: 42,
                color: AppColors.purple,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isSearching ? 'No notes found' : 'Start writing',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Try another keyword'
                  : 'Tap below to create your first note',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (!isSearching) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Create Note'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
