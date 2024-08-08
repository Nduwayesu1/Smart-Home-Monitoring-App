import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'light_sensor_view.dart'; // Adjust import path if necessary
import 'motion_sensor_view.dart'; // Adjust import path if necessary
import 'location_sensor_view.dart'; // Adjust import path if necessary

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({Key? key}) : super(key: key);

  @override
  _HomeDashboardState createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _launchCount = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadLaunchCount();
  }

  Future<void> _loadLaunchCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _launchCount = prefs.getInt('launch_count') ?? 0;
    });
  }

  void _onDrawerItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navigate to profile settings
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Navigation',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'App Launch Count: $_launchCount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.lightbulb),
              title: Text('Light Sensor'),
              onTap: () {
                _onDrawerItemTapped(0);
              },
            ),
            ListTile(
              leading: Icon(Icons.motion_photos_on),
              title: Text('Motion Sensor'),
              onTap: () {
                _onDrawerItemTapped(1);
              },
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Location Sensor'),
              onTap: () {
                _onDrawerItemTapped(2);
              },
            ),
          ],
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Motion'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'location'),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return LightSensorView();
      case 1:
        return MotionSensorView();
      case 2:
        return LocationSensorView();
      default:
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weather Section
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.blue.shade100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.cloud, size: 48),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('25°C', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                        const Text('Sunny', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Usage Statistics Section
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.green.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('App Usage Statistics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text('Number of times opened: $_launchCount', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 16),

                    // Example Graphical Overview
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: _generateUsageData(),
                              isCurved: true,
                              color: Colors.blue,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(show: false),
                            ),
                          ],
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: const Color(0xff37434d),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }

  List<FlSpot> _generateUsageData() {
    // Example data for the graph
    return [
      FlSpot(0, _launchCount.toDouble()),
      FlSpot(1, _launchCount.toDouble() * 1.2),
      FlSpot(2, _launchCount.toDouble() * 0.8),
      FlSpot(3, _launchCount.toDouble() * 1.5),
    ];
  }
}
