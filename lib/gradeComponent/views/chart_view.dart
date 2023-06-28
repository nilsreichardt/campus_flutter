import 'dart:math';

import 'package:campus_flutter/base/helpers/iconText.dart';
import 'package:campus_flutter/gradeComponent/viewModels/grade_viewmodel.dart';
import 'package:campus_flutter/providers_get_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartView extends ConsumerStatefulWidget {
  const ChartView({super.key, required this.studyID, required this.title});

  final String title;
  final String studyID;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChartViewState();
}

class _ChartViewState extends ConsumerState<ChartView> {
  late Map<double, int> data;

  @override
  void initState() {
    data = ref.read(gradeViewModel).chartDataForDegree(widget.studyID);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PopupMenuButton<String>(
          itemBuilder: (context) => ref.read(gradeViewModel).getMenuEntries(),
          onSelected: (selected) {
            ref.read(gradeViewModel).setSelectedDegree(selected);
          },
          child: IconText(
              iconData: Icons.keyboard_arrow_down,
              label: "${widget.title} ${widget.studyID}",
              style: Theme.of(context).textTheme.bodyLarge,
              mainAxisAlignment: MainAxisAlignment.center,
              leadingIcon: false),
        ),
        SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: data.values.reduce(max).toDouble(),
                interval: 1),
            series: <ChartSeries<MapEntry<double, int>, String>>[
              ColumnSeries<MapEntry<double, int>, String>(
                dataSource: data.entries.toList(),
                xValueMapper: (MapEntry<double, int> data, _) =>
                    data.key.toString(),
                yValueMapper: (MapEntry<double, int> data, _) => data.value,
                pointColorMapper: (MapEntry<double, int> data, _) =>
                    GradeViewModel.getColor(data.key),
              )
            ])
      ],
    );
  }
}