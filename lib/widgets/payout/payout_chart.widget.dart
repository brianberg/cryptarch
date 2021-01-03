import "dart:ui";

import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:fl_chart/fl_chart.dart";

import "package:cryptarch/constants/colors.dart";
import "package:cryptarch/models/models.dart" show Payout;
import "package:cryptarch/widgets/widgets.dart";

class PayoutChart extends StatelessWidget {
  final Map<String, dynamic> filters;
  final int limit;

  PayoutChart({
    Key key,
    this.filters,
    this.limit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fiatFormat = NumberFormat.simpleCurrency();
    final dateFormat = DateFormat("MM/dd/yy");

    return FutureBuilder<List<Payout>>(
      future: Payout.find(
        filters: this.filters,
        orderBy: "date DESC",
        limit: this.limit,
      ),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<Payout>> snapshot,
      ) {
        final chartSize = this._getChartSize(MediaQuery.of(context).size);
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return SizedBox(
              width: chartSize.width,
              height: chartSize.height,
              child: Center(
                child: LoadingIndicator(),
              ),
            );
          case ConnectionState.done:
            if (snapshot.hasError) {
              return SizedBox(
                width: chartSize.width,
                height: chartSize.height,
                child: Center(
                  child: Text("Error: ${snapshot.error}"),
                ),
              );
            }
            if (snapshot.data.isEmpty) {
              return SizedBox(
                width: chartSize.width,
                height: chartSize.height,
                child: Center(
                  child: Text("No payouts"),
                ),
              );
            }
            final List<Payout> payouts = snapshot.data;
            final List<FlSpot> spots = payouts.map((payout) {
              double x = payout.date.millisecondsSinceEpoch.toDouble();
              double y = double.parse(payout.value.toStringAsFixed(2));
              return FlSpot(x, y);
            }).toList();

            return LineChart(
              LineChartData(
                lineBarsData: <LineChartBarData>[
                  LineChartBarData(
                    colors: [
                      GRAPH_PURPLE_DARK,
                      GRAPH_PURPLE,
                      GRAPH_PURPLE_LIGHT,
                    ],
                    spots: spots,
                    isCurved: true,
                    dotData: FlDotData(show: false),
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: SideTitles(
                    showTitles: true,
                    getTitles: (double value) {
                      if (value.floor() % 5 == 0) {
                        return "\$${value.floor()}";
                      }
                      return "";
                    },
                    getTextStyles: (double value) {
                      return TextStyle(
                        color: theme.textTheme.subtitle2.color,
                        fontSize: theme.textTheme.caption.fontSize,
                        fontFeatures: [FontFeature.tabularFigures()],
                      );
                    },
                  ),
                  bottomTitles: SideTitles(showTitles: false),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: theme.colorScheme.surface,
                      getTooltipItems: (List<LineBarSpot> spots) {
                        return spots.map((spot) {
                          final value = fiatFormat.format(spot.y);
                          final date = DateTime.fromMillisecondsSinceEpoch(
                            spot.x.toInt(),
                          );
                          return LineTooltipItem(
                            "$value\n${dateFormat.format(date)}",
                            theme.textTheme.bodyText1.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          );
                        }).toList();
                      }),
                ),
                gridData: FlGridData(
                  checkToShowHorizontalLine: (double value) {
                    return value.floor() % 5 == 0;
                  },
                ),
                borderData: FlBorderData(show: false),
              ),
            );
        }
        return Container(
          child: const Text("Unable to payouts data"),
        );
      },
    );
  }

  Size _getChartSize(Size screenSize) {
    Size resultSize;
    if (screenSize.width < screenSize.height) {
      resultSize = Size(screenSize.width, screenSize.width);
    } else if (screenSize.height < screenSize.width) {
      resultSize = Size(screenSize.height, screenSize.height);
    } else {
      resultSize = Size(screenSize.width, screenSize.height);
    }
    return resultSize * 0.7;
  }
}
