import 'dart:async';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:tangankanan/models/pledge.dart';
import 'package:tangankanan/services/database_service.dart';
import 'package:tangankanan/models/project.dart';
import 'package:tangankanan/views/style.dart';

class FundingProgressPage extends StatefulWidget {
  final Project project;

  const FundingProgressPage({Key? key, required this.project})
      : super(key: key);

  @override
  _FundingProgressPageState createState() => _FundingProgressPageState();
}

class _FundingProgressPageState extends State<FundingProgressPage> {
  late Future<List<Pledge>> _pledgesFuture;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pledgesFuture = _fetchPledges();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<List<Pledge>> _fetchPledges() {
    return DatabaseService().fetchPledgesByProjectId(widget.project.projectId);
  }

  Future<void> _refreshData() async {
    setState(() {
      _pledgesFuture = _fetchPledges();
    });
    await _pledgesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Funding Progress'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<Pledge>>(
            future: _pledgesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No pledges found'));
              } else {
                final pledges = snapshot.data!;
                final data = _aggregatePledgeData(pledges);
                final totalFunds = data.isNotEmpty ? data.last.amount : 0;
                final uniqueBackers = _getUniqueBackers(pledges);
                final numberOfBackers = uniqueBackers.length;
                final goalProgress =
                    (totalFunds / widget.project.fundGoal) * 100;

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProjectDetails(
                          totalFunds.toDouble(), numberOfBackers, goalProgress),
                      SizedBox(height: 20),
                      Text(
                        'Funding Progress Over Time',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      _buildFundHistoryChart(data),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  List<FundHistory> _aggregatePledgeData(List<Pledge> pledges) {
    pledges.sort((a, b) => a.date.compareTo(b.date));
    double cumulativeAmount = 0;
    return pledges.map((pledge) {
      cumulativeAmount += pledge.amount;
      return FundHistory(pledge.date, cumulativeAmount);
    }).toList();
  }

  Set<String> _getUniqueBackers(List<Pledge> pledges) {
    return pledges.map((pledge) => pledge.userId).toSet();
  }

  Widget _buildProjectDetails(
      double totalFunds, int numberOfBackers, double goalProgress) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        decoration: AppStyles().cardDecoration(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.project.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                widget.project.description,
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 20),
              _buildInfoRow(
                  'Total Funds Raised', 'RM ${totalFunds.toStringAsFixed(2)}'),
              _buildInfoRow('Funding Goal',
                  'RM ${widget.project.fundGoal.toStringAsFixed(2)}'),
              _buildInfoRow('Progress', '${goalProgress.toStringAsFixed(1)}%'),
              _buildInfoRow('Number of Backers', '$numberOfBackers'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildFundHistoryChart(List<FundHistory> data) {
    final series = [
      charts.Series<FundHistory, DateTime>(
        id: 'FundHistory',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (FundHistory fundHistory, _) => fundHistory.date,
        measureFn: (FundHistory fundHistory, _) => fundHistory.amount,
        data: data,
      )
    ];

    return SizedBox(
      height: 300,
      child: charts.TimeSeriesChart(
        series,
        animate: true,
        dateTimeFactory: const charts.LocalDateTimeFactory(),
      ),
    );
  }
}

class FundHistory {
  final DateTime date;
  final double amount;

  FundHistory(this.date, this.amount);
}
