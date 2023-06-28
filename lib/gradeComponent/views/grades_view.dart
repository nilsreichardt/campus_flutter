import 'package:campus_flutter/base/helpers/delayedLoadingIndicator.dart';
import 'package:campus_flutter/base/helpers/last_updated_text.dart';
import 'package:campus_flutter/base/helpers/cardWithPadding.dart';
import 'package:campus_flutter/base/helpers/paddedDivider.dart';
import 'package:campus_flutter/base/helpers/semester_calculator.dart';
import 'package:campus_flutter/base/helpers/stringParser.dart';
import 'package:campus_flutter/base/views/generic_stream_builder.dart';
import 'package:campus_flutter/base/views/error_handling_view.dart';
import 'package:campus_flutter/gradeComponent/model/grade.dart';
import 'package:campus_flutter/gradeComponent/viewModels/grade_viewmodel.dart';
import 'package:campus_flutter/gradeComponent/views/chart_view.dart';
import 'package:campus_flutter/gradeComponent/views/grade_view.dart';
import 'package:campus_flutter/providers_get_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GradesView extends ConsumerStatefulWidget {
  const GradesView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GradesViewState();
}

class _GradesViewState extends ConsumerState<GradesView> {
  late GradeViewModel gradeVM;

  @override
  void didChangeDependencies() {
    gradeVM = ref.watch(gradeViewModel);
    gradeVM.fetch(false);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return GenericStreamBuilder<Map<String, List<Grade>>>(
        stream: gradeVM.studyProgramGrades,
        dataBuilder: (context, data) {
          if (data.isEmpty) {
            return const Text("no grades found");
          } else {
            final lastFetched = ref.read(gradeViewModel).lastFetched.value;
            return RefreshIndicator(
                child: Scrollbar(
                    child: SingleChildScrollView(
                        clipBehavior: Clip.antiAlias,
                        child: Column(children: [
                          if (lastFetched != null) LastUpdatedText(lastFetched),
                            DegreeView(degree: data),
                        ]))),
                onRefresh: () async {
                  ref.read(gradeViewModel).fetch(true);
                });
          }
        },
        errorBuilder: (context, error) => ErrorHandlingView(
              error: error,
              errorHandlingViewType: ErrorHandlingViewType.fullScreen,
              retry: ref.read(gradeViewModel).fetch,
            ),
        loadingBuilder: (context) =>
            const DelayedLoadingIndicator(name: "Grades"));
  }
}

class DegreeView extends StatelessWidget {
  const DegreeView({super.key, required this.degree});

  final Map<String, List<Grade>> degree;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CardWithPadding(
            child: ChartView(
                studyID: degree.values.first.firstOrNull?.studyID ?? "Unknown",
                title: degree.values.first.firstOrNull?.studyDesignation ?? "Unknown")),
        for (var semester in degree.entries)
          SemesterView(semester: semester),
      ],
    );
  }
}

class SemesterView extends StatelessWidget {
  const SemesterView({super.key, required this.semester});

  final MapEntry<String, List<Grade>> semester;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ExpansionTile(
      title: Text(StringParser.toFullSemesterName(semester.key)),
      initiallyExpanded:
          (semester.key == SemesterCalculator.getCurrentSemester() ||
              semester.key == SemesterCalculator.getPriorSemester()),
      children: [
        for (var index = 0; index < semester.value.length; index++)
          Column(children: [
            GradeRowAlt(grade: semester.value[index]),
            (index != semester.value.length - 1
                ? const PaddedDivider()
                : const SizedBox.shrink())
          ])
      ],
    ));
  }
}