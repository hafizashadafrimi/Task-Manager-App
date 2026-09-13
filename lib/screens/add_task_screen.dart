import 'package:flutter/material.dart';

import '../models/api_response.dart';
import '../service/api_caller.dart';
import '../utils/task_refresh_bus.dart';
import '../utils/urls.dart';

class AddNewTaskScreen extends StatefulWidget {
  const AddNewTaskScreen({super.key});
  @override
  State<AddNewTaskScreen> createState() => _AddNewTaskScreenState();
}

class _AddNewTaskScreenState extends State<AddNewTaskScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool submitting = false;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => submitting = true);
    final String createdDate = DateTime.now().toUtc().toIso8601String();

    final ApiResponse response = await ApiCaller.postRequest(
      url: Urls.addNewTaskURL,
      body: {
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'status': 'New',
        'createdDate': createdDate,
      },
    );
    if (!mounted) return;
    setState(() => submitting = false);
    if (response.isSuccess) {
      TaskRefreshBus.instance.notifyTasksChanged();
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.errorMessage ?? 'Unable to create task. Please try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create task')),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.viewInsetsOf(context).bottom + 28,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 40,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary
                            .withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.edit_note_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'What needs to be done?',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your task text is stored exactly as you enter it. You can write your task in Bangla or English.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 28),
                    const Text('Task title'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: titleController,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      maxLength: 120,
                      decoration: const InputDecoration(
                        hintText: 'Enter task title',
                        counterText: '',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Please enter a task title'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    const Text('Description'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: descriptionController,
                      minLines: 5,
                      maxLines: null,
                      maxLength: 1000,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: 'Enter task description',
                        alignLabelWithHint: true,
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Please enter a description'
                          : null,
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: submitting ? null : submit,
                      child: submitting
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Create task'),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
