import 'package:campus_flutter/base/enums/error_handling_view_type.dart';
import 'package:campus_flutter/base/helpers/card_with_padding.dart';
import 'package:campus_flutter/base/helpers/delayed_loading_indicator.dart';
import 'package:campus_flutter/base/errorHandling/error_handling_router.dart';
import 'package:campus_flutter/departuresComponent/model/departure.dart';
import 'package:campus_flutter/departuresComponent/model/station.dart';
import 'package:campus_flutter/departuresComponent/viewModel/departures_viewmodel.dart';
import 'package:campus_flutter/departuresComponent/views/departures_details_row_view.dart';
import 'package:campus_flutter/departuresComponent/views/departures_details_view.dart';
import 'package:campus_flutter/homeComponent/split_view_viewmodel.dart';
import 'package:campus_flutter/homeComponent/widgetComponent/views/widget_frame_view.dart';
import 'package:campus_flutter/base/extensions/context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeparturesHomeWidget extends ConsumerStatefulWidget {
  const DeparturesHomeWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DeparturesHomeWidgetState();
}

class _DeparturesHomeWidgetState extends ConsumerState<DeparturesHomeWidget> {
  @override
  void deactivate() {
    ref.read(departureViewModel).timer?.cancel();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ref.watch(departureViewModel).departures,
      builder: (context, snapshot) {
        return WidgetFrameView(
          title: _titleBuilder(),
          child: GestureDetector(
            onTap: () => _onWidgetPressed(context),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.225,
              ),
              child: CardWithPadding(
                child: StreamBuilder(
                  stream: ref.watch(departureViewModel).departures,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final station =
                          ref.watch(departureViewModel).selectedStation.value!;
                      return _widgetContent(snapshot, station);
                    } else if (snapshot.hasError) {
                      return ErrorHandlingRouter(
                        error: snapshot.error!,
                        errorHandlingViewType: ErrorHandlingViewType.textOnly,
                        retry: ref.read(departureViewModel).fetch,
                      );
                    } else {
                      return DelayedLoadingIndicator(
                        name: context.localizations.departures,
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _titleBuilder() {
    if (ref.watch(departureViewModel).closestCampus.value?.name != null) {
      return "${context.localizations.departures} @ ${ref.watch(departureViewModel).closestCampus.value?.name}";
    } else {
      return context.localizations.departures;
    }
  }

  Widget _widgetContent(
    AsyncSnapshot<List<Departure>?> snapshot,
    Station station,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: "${context.localizations.station} ",
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(
                text: station.name,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (snapshot.data!.isEmpty)
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.15,
            ),
            child: const Center(
              child: Text("No Departures Found"),
            ),
          ),
        if (snapshot.data!.isNotEmpty)
          for (var departure in snapshot.data!.length > 3
              ? snapshot.data!.getRange(0, 3)
              : snapshot.data!) ...[
            const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
            DeparturesDetailsRowView(departure: departure),
          ],
      ],
    );
  }

  _onWidgetPressed(BuildContext context) {
    if (MediaQuery.orientationOf(context) == Orientation.portrait) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const DeparturesDetailsScaffold(),
        ),
      );
    } else {
      ref.read(homeSplitViewModel).selectedWidget.add(
            const DeparturesDetailsScaffold(
              isSplitView: true,
            ),
          );
    }
  }
}
