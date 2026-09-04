import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/core/widgets/custom_textfield.dart';
import 'package:tutor_tech/features/subject/subject_model.dart';

import 'package:tutor_tech/features/tutor/provider/tutor_provider.dart';

import '../../../core/constants/app_text_styles.dart';

class AssignSessionScreen extends ConsumerStatefulWidget {

  const AssignSessionScreen({super.key,});

  @override
  ConsumerState<AssignSessionScreen> createState() => _AssignSessionScreenState();
}

class _AssignSessionScreenState extends ConsumerState<AssignSessionScreen> {
  final TextEditingController _title = TextEditingController();
  String _selectedSubject = 'gcse_maths';
String? _selectedTutorId;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 80,left: 10,right: 10),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            CustomTextField(label: 'Classroom Title', controller: _title),

            const SizedBox(height: 16),
            Text('Step 1: Select Subject *', style: AppTextStyles.labelLarge),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedSubject,
              items: seededSubjects.map((e) {
                return DropdownMenuItem(
                  value: e.slug,
                  child: Text('${e.emoji} ${e.displayName}'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                 setState(() {
                   _selectedSubject = val;
                 });
                }
              },
            ),
            const SizedBox(height: 16),

            // Dynamic Tutor Selector SECOND
            Text('Step 2: Assign Tutor (Filtered by Subject & Availability) *', style: AppTextStyles.labelLarge),
            const SizedBox(height: 6),


          ],
        ),
      ),
    );
  }
}
