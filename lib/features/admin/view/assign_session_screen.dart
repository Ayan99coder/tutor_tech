import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/features/subjects/subject_model.dart';

class AssignSessionScreen extends ConsumerStatefulWidget {
  const AssignSessionScreen({super.key});

  @override
  ConsumerState<AssignSessionScreen> createState() =>
      _AssignSessionScreenState();
}

class _AssignSessionScreenState extends ConsumerState<AssignSessionScreen> {
  final _titleController = TextEditingController();
  String? _selectedTutorId;
  String _selectedSubject = 'gcse_maths';
void _updateFiltered(){

}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            DropdownButtonFormField(
              onChanged: (val) {
                setState(() {
                  _selectedSubject = val;
                });
              },
              initialValue: _selectedSubject,
              items: seededSubjects.map((e) {
                return DropdownMenuItem(child: Text(e.slug));
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
