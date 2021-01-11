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
  final bool showRevenue;
  final bool showCost;
  final bool showCheckboxes;

  MinerProfitChart({
    Key key,
    this.filters,
    this.limit,
    this.showRevenue = true,
    this.showCost = true,
    this.showCheckboxes = false,
  }) : super(key: key);

  @override
  _MinerProfitChartState createState() => _MinerProfitChartState();
}

class _MinerProfitChartState extends State<MinerProfitChart> {
  final fiatFormat = NumberFormat.simpleCurrency();
  final dateFormat = DateFormat("MM/dd/yy");

  List<FlSpot> costSpots;
  List<FlSpot> revenueSpots;
  List<FlSpot> profitSpots;
  bool isBusy = true;
  bool showRevenueSpots = false;
  bool showCostSpots = false;
  bool showProfitSpots = true;

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

    final List<LineChartBarData> lines = [];
    if (this.revenueSpots != null) {
      lines.add(LineChartBarData(
        colors: [
          GRAPH_GREEN_DARK,
          GRAPH_GREEN,
          GRAPH_GREEN_LIGHT,
        ],
        spots: this.revenueSpots,
        isCurved: true,
        show: this.showRevenueSpots,
        dotData: FlDotData(show: this.revenueSpots.length == 1),
      ));
    }
    lines.add(LineChartBarData(
      colors: [
        GRAPH_PURPLE_DARK,
        GRAPH_PURPLE,
        GRAPH_PURPLE_LIGHT,
      ],
      spots: this.profitSpots,
      isCurved: true,
      show: this.showProfitSpots,
      dotData: FlDotData(show: this.profitSpots.length == 1),
    ));
    if (this.costSpots != null) {
      lines.add(LineChartBarData(
        colors: [
          GRAPH_BLUE_DARK,
          GRAPH_BLUE,
          GRAPH_BLUE_LIGHT,
        ],
        spots: this.costSpots,
        isCurved: true,
        show: this.showCostSpots,
        dotData: FlDotData(show: this.costSpots.length == 1),
      ));
    }

    return Column(
      children: [
        this.widget.showCheckboxes
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Row(
                      children: [
                        Checkbox(
                          value: this.showProfitSpots,
                          activeColor: GRAPH_PURPLE,
                          onChanged: (value) {
                            setState(() {
                              this.showProfitSpots = value;
                            });
                          },
                        ),
                        Text("Profit"),
                      ],
                    ),
                  ),
                  this.widget.showRevenue
                      ? Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Row(
                            children: [
                              Checkbox(
                                value: this.showRevenueSpots,
                                activeColor: GRAPH_GREEN,
                                onChanged: (value) {
                                  setState(() {
                                    this.showRevenueSpots = value;
                                  });
                                },
                              ),
                              Text("Revenue"),
                            ],
                          ),
                        )
                      : null,
                  this.widget.showCost
                      ? Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Row(
                            children: [
                              Checkbox(
                                value: this.showCostSpots,
                                activeColor: GRAPH_BLUE,
                                onChanged: (value) {
                                  setState(() {
                                    this.showCostSpots = value;
                                  });
                                },
                              ),
                              Text("Cost"),
                            ],
                          ),
                        )
                      : null,
                ].where((w) => w != null).toList(),
              )
            : Container(),
        SizedBox(
          width: double.infinity,
          child: LineChart(
            LineChartData(
              minY: 0.0,
              lineBarsData: lines,
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
          ),
        ),
      ],
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

    List<FlSpot> costSpots;
    List<FlSpot> revenueSpots;

    if (this.widget.showCost) {
      costSpots = energyUsage.map((energy) {
        double x = energy.date.millisecondsSinceEpoch.toDouble();
        double y = double.parse(energy.cost.toStringAsFixed(2));
        return FlSpot(x, y);
      }).toList();
    }

    if (this.widget.showRevenue) {
      revenueSpots = [];
    }

    final List<FlSpot> profitSpots = [];
    for (Payout payout in payouts) {
      final x = payout.date.millisecondsSinceEpoch.toDouble();
      if (this.widget.showRevenue) {
        revenueSpots.add(FlSpot(
          x,
          double.parse(payout.value.toStringAsFixed(2)),
        ));
      }
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
      this.costSpots = costSpots;
      this.revenueSpots = revenueSpots;
      this.profitSpots = profitSpots;
    });
  }
}
