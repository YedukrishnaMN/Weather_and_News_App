import 'package:flutter/material.dart';
import 'package:weather_news_dashboard/features/weather/data/weather_service.dart';
import 'package:weather_news_dashboard/features/weather/data/weather_model.dart';
import 'package:weather_news_dashboard/core/location/location_service.dart';
import 'package:weather_news_dashboard/features/weather/data/forecast_model.dart';
import 'weather_alerts_screen.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  late Future<Weather>? _weatherFuture;
  late Future<List<Forecast>> _forecastFuture;
  String city = "Current Location";

  List<String> predefinedCities = ['New York', 'Tokyo', 'Paris', 'Dubai'];
  final Map<String, Future<Weather>> cityWeatherFutures = {};

  void _fetchWeather() async {
    final cityInput = _cityController.text.trim();

    if (cityInput.isEmpty) {
      try {
        final position = await LocationService.getCurrentLocation();
        final lat = position.latitude;
        final lon = position.longitude;

        setState(() {
          _weatherFuture = WeatherService().fetchWeatherByCoordinates(lat, lon);
          _forecastFuture = WeatherService().fetch5DayForecast(lat, lon);
          city = "Current Location";
        });
      } catch (e) {
        print('Location access denied or failed: $e');

        setState(() {
          _weatherFuture = WeatherService().fetchWeather("London");
          WeatherService().getCoordinatesFromCity("London").then((coords) {
            _forecastFuture = WeatherService().fetch5DayForecast(
              coords['lat']!,
              coords['lon']!,
            );
          });

          city = "London (Default)";
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Location denied. Showing weather for London."),
          ),
        );
      }
    } else {
      try {
        final coords = await WeatherService().getCoordinatesFromCity(cityInput);

        setState(() {
          _weatherFuture = WeatherService().fetchWeather(cityInput);
          _forecastFuture = WeatherService().fetch5DayForecast(
            coords['lat']!,
            coords['lon']!,
          );
          city = cityInput;
        });
      } catch (e) {
        print("Error fetching city weather: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load weather for $cityInput')),
        );
      }
    }
  }

  void _fetchWeatherForComparisonCity(String selectedCity) {
    setState(() {
      _cityController.text = selectedCity;
      _fetchWeather();
    });
  }

  void _fetchPredefinedCitiesWeather() {
    for (var city in predefinedCities) {
      cityWeatherFutures[city] = WeatherService().fetchWeather(city);
    }
  }

  @override
  void initState() {
    super.initState();
    _cityController.text = '';
    _fetchWeather();
    _fetchPredefinedCitiesWeather();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.warning_amber),
            tooltip: 'Weather Alerts',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WeatherAlertsScreen(),
                ),
              );
            },
          ),
        ],
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newCity = await showDialog<String>(
            context: context,
            builder: (context) {
              final controller = TextEditingController();
              return AlertDialog(
                title: const Text('Add City'),
                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: 'Enter city name'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, controller.text.trim()),
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );

          if (newCity != null && newCity.isNotEmpty) {
            setState(() {
              predefinedCities.add(newCity);
              cityWeatherFutures[newCity] = WeatherService().fetchWeather(newCity);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Enter city',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _fetchWeather,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Weather: $city',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            FutureBuilder<Weather>(
              future: _weatherFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData) {
                  return const Text('No weather data available');
                }

                final weather = snapshot.data!;
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Image.network(
                      'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.cloud),
                    ),
                    title: Text('${weather.description}'),
                    subtitle: Text('Temp: ${weather.temperature}°C'),
                    trailing: Text('${weather.cityName}'),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            const Text(
              'Compare with other cities:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: predefinedCities.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final city = predefinedCities[index];
                  return GestureDetector(
                    onTap: () => _fetchWeatherForComparisonCity(city),
                    child: FutureBuilder<Weather>(
                      future: cityWeatherFutures[city],
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            width: 120,
                            padding: const EdgeInsets.all(8),
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        } else if (snapshot.hasError) {
                          return Container(
                            width: 120,
                            padding: const EdgeInsets.all(8),
                            child: const Center(child: Icon(Icons.error)),
                          );
                        } else if (!snapshot.hasData) {
                          return Container(
                            width: 120,
                            padding: const EdgeInsets.all(8),
                            child: const Text('No data'),
                          );
                        }

                        final weather = snapshot.data!;
                        return Container(
                          width: 140,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(weather.cityName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Image.network(
                                'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                                width: 50,
                                height: 50,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.cloud),
                              ),
                              const SizedBox(height: 6),
                              Text('${weather.temperature}°C'),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
