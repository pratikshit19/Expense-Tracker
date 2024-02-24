import 'package:expense_tracker/bar%20graph/individual_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummary;
  final int startMonth;

  const MyBarGraph(
      {super.key, required this.monthlySummary, required this.startMonth});

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  //this list will hold the data for each bar
  List<IndividualBar> barData = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => scrollToEnd);
  }

  void initializeBarData() {
    barData = List.generate(
      12,
      (index) {
        int dataIndex = (widget.startMonth + index) % 12;
        // Adjust the start point to render from January
        int adjustedIndex = (12 + dataIndex - widget.startMonth - 1) % 12;
        double yValue =
            (adjustedIndex >= 0 && adjustedIndex < widget.monthlySummary.length)
                ? widget.monthlySummary[adjustedIndex]
                : 0.0;
        return IndividualBar(x: index, y: yValue);
      },
    );
  }

  //initialize bar data
  double calculateMax() {
    //initially set at 500, but adjust if spending is past this
    double max = 5000;

    //get the month with highest amount
    widget.monthlySummary.sort();

    //increase the upper limit by a bit
    max = widget.monthlySummary.last * 1.05;

    if (max < 5000) {
      return 5000;
    }

    return max;
  }

  //scroll controller to make sure it scrolls to the end
  final ScrollController _scrollController = ScrollController();
  void scrollToEnd() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);
  }

  @override
  Widget build(BuildContext context) {
    initializeBarData();

    double barWidth = 15;
    double spaceBetweenBars = 12;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SizedBox(
          width: barWidth * barData.length +
              spaceBetweenBars * (barData.length - 1),
          child: BarChart(
            BarChartData(
                minY: 0,
                maxY: calculateMax(),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(
                  show: true,
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: getBottomTiles,
                          reservedSize: 24)),
                ),
                barGroups: barData
                    .map(
                      (data) => BarChartGroupData(
                        x: data.x,
                        barRods: [
                          BarChartRodData(
                            toY: data.y,
                            width: barWidth,
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.blueAccent,
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: calculateMax(),
                              color: Colors.grey.shade900,
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
                alignment: BarChartAlignment.center,
                groupsSpace: spaceBetweenBars),
          ),
        ),
      ),
    );
  }
}

Widget getBottomTiles(double value, TitleMeta meta) {
  const textStyle = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  String text;
  switch ((value.toInt()) % 12) {
    case 0:
      text = "J";
      break;
    case 1:
      text = "F";
      break;
    case 2:
      text = "M";
      break;
    case 3:
      text = "A";
      break;
    case 4:
      text = "M";
      break;
    case 5:
      text = "J";
      break;
    case 6:
      text = "J";
      break;
    case 7:
      text = "A";
      break;
    case 8:
      text = "S";
      break;
    case 9:
      text = "O";
      break;
    case 10:
      text = "N";
      break;
    case 11:
      text = "D";
      break;

    default:
      text = '';
      break;
  }
  return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        text,
        style: textStyle,
      ));
}
