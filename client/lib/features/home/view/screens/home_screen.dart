import 'package:client/core/theme/theme.dart';
import 'package:client/features/home/view/screens/profile_screen.dart';
import 'package:client/features/home/view/widgets/search_screen.dart';
import 'package:client/features/home/view/widgets/stats_header.dart';
import 'package:client/features/home/view/widgets/filter_chips.dart';
import 'package:client/features/home/view/widgets/exit_dialog.dart';
import 'package:client/features/home/view/widgets/custom_app_bar.dart';
import 'package:client/features/home/view/widgets/tile_widget.dart';
import 'package:client/features/verify/view/verify_screen.dart';
import 'package:client/features/verify/viewmodel/attendance_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/features/home/viewmodel/student_state_notifier.dart';
import 'dart:ui';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with RouteAware, SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _filters = [
    {"label": "All", "icon": Icons.grid_view_rounded},
    {"label": "Present", "icon": Icons.check_circle_outline},
    {"label": "Absent", "icon": Icons.cancel_outlined},
    {"label": "1st", "icon": Icons.looks_one_rounded},
    {"label": "2nd", "icon": Icons.looks_two_rounded},
  ];

  String _selectedFilter = "All";
  late AnimationController _filterAnimController;
  DateTime? _lastPressedAt;

  @override
  void initState() {
    super.initState();
    _filterAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _filterAnimController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {
      _selectedFilter = "All";
    });
    super.didPopNext();
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentNotifierProvider);
    final attendanceNotifier = ref.read(studentNotifierProvider.notifier);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: studentsAsync.when(
          data: (students) {
            List filteredStudents = _filterStudents(students);

            return RefreshIndicator(
              onRefresh: () async {
                await attendanceNotifier.refresh();
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  CustomAppBar(
                    onMenuPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                    onSearchPressed: () {
                      showSearch(
                        context: context,
                        delegate: StudentSearchDelegate(students),
                      );
                    },
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  SliverToBoxAdapter(
                    child: FilterChips(
                      filters: _filters,
                      selectedFilter: _selectedFilter,
                      onFilterChanged: (filter) {
                        setState(() => _selectedFilter = filter);
                        _filterAnimController.forward(from: 0);
                      },
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: StatsHeader(
                        allStudents: students,
                        filteredStudents: filteredStudents,
                        onScanPressed: _navigateToScanner,
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final student = filteredStudents[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TileWidget(
                            name: student.name,
                            studentId: student.studentId,
                            year: student.year,
                            email: student.email,
                            phone: student.phone,
                            isPresent: student.isPresent,
                            onTogglePresence: () {
                              attendanceNotifier.updateAttendance(
                                student.studentId,
                                !student.isPresent,
                              );
                              attendanceNotifier.refresh();
                            },
                          ),
                        );
                      }, childCount: filteredStudents.length),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            );
          },
          error: (error, stackTrace) => Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.claymorphicDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.error.withOpacity(0.2),
                          AppColors.error.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Something went wrong",
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          loading: () => Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.claymorphicDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: const CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_selectedFilter != "All") {
      setState(() {
        _selectedFilter = "All";
      });
      return false;
    }

    final now = DateTime.now();
    const maxDuration = Duration(seconds: 2);
    final isWarning =
        _lastPressedAt == null || now.difference(_lastPressedAt!) > maxDuration;

    if (isWarning) {
      _lastPressedAt = now;

      final shouldExit = await showExitDialog(context);
      if (shouldExit == true) {
        return true;
      }
      return false;
    }

    return true;
  }

  void _navigateToScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VerifyScreen()),
    );
  }

  List _filterStudents(List students) {
    switch (_selectedFilter) {
      case "Present":
        return students.where((s) => s.isPresent).toList();
      case "Absent":
        return students.where((s) => !s.isPresent).toList();
      case "1st":
        return students.where((s) => s.year == '1').toList();
      case "2nd":
        return students.where((s) => s.year == '2').toList();
      case "All":
      default:
        return students;
    }
  }
}

extension GradientOpacity on Gradient {
  Gradient withOpacity(double opacity) {
    if (this is LinearGradient) {
      final gradient = this as LinearGradient;
      return LinearGradient(
        colors: gradient.colors.map((c) => c.withOpacity(opacity)).toList(),
        begin: gradient.begin,
        end: gradient.end,
      );
    }
    return this;
  }
}
