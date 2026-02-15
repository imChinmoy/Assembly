import 'package:client/core/theme/theme.dart';
import 'package:client/features/home/view/widgets/tile_widget.dart';
import 'package:flutter/material.dart';

class StudentSearchDelegate extends SearchDelegate {
  final List students;
  StudentSearchDelegate(this.students);

  @override
  String? get searchFieldLabel => "Search by name or ID";

  @override
  TextStyle? get searchFieldStyle =>
      const TextStyle(color: Colors.white, fontSize: 16);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarThemeData(
        backgroundColor: AppColors.surface,
        iconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
        titleTextStyle: theme.textTheme.titleLarge,
        toolbarTextStyle: theme.textTheme.bodyMedium,
        toolbarHeight: 80,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = students
        .where(
          (s) =>
              s.name.toLowerCase().contains(query.toLowerCase()) ||
              s.studentId.contains(query),
        )
        .toList();

    return _buildResultList(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = students
        .where(
          (s) =>
              s.name.toLowerCase().contains(query.toLowerCase()) ||
              s.studentId.contains(query),
        )
        .toList();

    return _buildResultList(suggestions);
  }

  Widget _buildResultList(List results) {
    if (results.isEmpty) {
      return const Center(
        child: Text("No students found", style: TextStyle(color: Colors.white)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final student = results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: TileWidget(
            name: student.name,
            studentId: student.studentId,
            year: student.year,
            email: student.email,
            phone: student.phone,
          ),
        );
      },
    );
  }
}
