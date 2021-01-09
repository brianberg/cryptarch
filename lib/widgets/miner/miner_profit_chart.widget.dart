import "dart:ui";

import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:fl_chart/fl_chart.dart";

import "package:cryptarch/constants/colors.dart";
import "package:cryptarch/models/models.dart" show Energy, Payout;
import "package:cryptarch/widgets/widgets.dart";

class MinerProfitChart extends StatefulWidget {
  final Map<String, dynamic> filters;
  final int limit;

  MinerProfitChart({
    Key key,
    this.filters,
    this.limit,
  }) : super(key: key);

  @override
  _MinerProfitChartState createState() => _MinerProfitChartState();
}

class _MinerProfitChartState extends State<MinerProfitChart> {
  final fiatFormat = NumberFormat.simpleCurrency();
  final dateFormat = DateFormat("MM/dd/yy");

  List<FlSpot> energySpots;
  List<FlSpot> payoutSpots;
  List<FlSpot> profitSpots;
  bool isBusy = true;

  @override
  void initState() {
    super.initState();
    this._getData();
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      this.isBusy = true;
    });
    this._getData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chartSize = this._getChartSize(MediaQuery.of(context).size);

    if (this.isBusy) {
      return SizedBox(
        width: chartSize.width,
        height: chartSize.height,
        child: Center(
          child: LoadingIndicator(),
        ),
      );
    }

    return LineChart(
      LineChartData(
        minY: 0.0,
        lineBarsData: <LineChartBarData>[
          LineChartBarData(
            colors: [
              GRAPH_GREEN_DARK,
              GRAPH_GREEN,
              GRAPH_GREEN_LIGHT,
            ],
            spots: payoutSpots,
            isCurved: true,
            dotData: FlDotData(show: payoutSpots.length == 1),
          ),
          LineChartBarData(
            colors: [
              GRAPH_PURPLE_DARK,
              GRAPH_PURPLE,
              GRAPH_PURPLE_LIGHT,
            ],
            spots: profitSpots,
            isCurved: true,
            dotData: FlDotData(show: profitSpots.length == 1),
          ),
          LineChartBarData(
            colors: [
              GRAPH_BLUE_DARK,
              GRAPH_BLUE,
              GRAPH_BLUE_LIGHT,
            ],
            spots: energySpots,
            isCurved: true,
            dotData: FlDotData(show: energySpots.length == 1),
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
              final date = DateTime.fromMillisecondsSinceEpoch(
                spots.first.x.toInt(),
              );
              return spots.map((spot) {
                String value = fiatFormat.format(spot.y);
                if (spot == spots.last) {
                  value = "$value\n${dateFormat.format(date)}";
                }
                return LineTooltipItem(
                  value,
                  theme.textTheme.bodyText1.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                );
              }).toList();
            },
          ),
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

  Future<void> _getData() async {
    final payouts = await Payout.find(
      filters: this.widget.filters,
      orderBy: "date DESC",
      limit: this.widget.limit,
    );
    final energyUsage = await Energy.find(
      filters: this.widget.filters,
      orderBy: "date DESC",
      limit: this.widget.limit,
    );
    final Map<DateTime, Energy> energyLookup = {};
    for (Energy energy in energyUsage) {
      energyLookup[energy.date] = energy;
    }
    final List<FlSpot> energySpots = energyUsage.map((energy) {
      double x = energy.date.millisecondsSinceEpoch.toDouble();
      double y = double.parse(energy.cost.toStringAsFixed(2));
      return FlSpot(x, y);
    }).toList();
    final List<FlSpot> payoutSpots = [];
    final List<FlSpot> profitSpots = [];
    for (Payout payout in payouts) {
      final x = payout.date.millisecondsSinceEpoch.toDouble();
      payoutSpots.add(FlSpot(
        x,
        double.parse(payout.value.toStringAsFixed(2)),
      ));
      final energy = energyLookup[payout.date];
      if (energy != null) {
        final profit = payout.value - energy.cost;
        profitSpots.add(FlSpot(
          x,
          double.parse(profit.toStringAsFixed(2)),
        ));
      }
    }
    setState(() {
      this.isBusy = false;
      this.payoutSpots = payoutSpots;
      this.energySpots = energySpots;
      this.profitSpots = profitSpots;
    });
  }
}
