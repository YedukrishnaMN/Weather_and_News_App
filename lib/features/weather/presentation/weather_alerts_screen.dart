import 'package:flutter/material.dart';
import 'package:weather_news_dashboard/features/weather/data/weather_service.dart';
import 'package:weather_news_dashboard/features/weather/data/weather/weather_alert.dart';
import 'package:weather_news_dashboard/core/location/location_service.dart'; 

class WeatherAlertsScreen extends StatefulWidget {
  const WeatherAlertsScreen({super.key});

  @override
  State<WeatherAlertsScreen> createState() => _WeatherAlertsScreenState();
}

class _WeatherAlertsScreenState extends State<WeatherAlertsScreen> {
  late Future<List<WeatherAlert>> _alertsFuture;

  @override
  void initState() {
    super.initState();
    _alertsFuture = _fetchAlerts();
  }

  Future<List<WeatherAlert>> _fetchAlerts() async {
    try {
      final position = await LocationService.getCurrentLocation();
      return await WeatherService().fetchWeatherAlerts(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      print('Error fetching alerts: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather Alerts')),
      body: FutureBuilder<List<WeatherAlert>>(
        future: _alertsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final alerts = snapshot.data ?? [];

          if (alerts.isEmpty) {
            return const Center(child: Text('No alerts available.'));
          }

          return ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(alert.event),
                  subtitle: Text(alert.description),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
