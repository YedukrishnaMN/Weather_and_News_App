import 'dart:convert';
import 'package:http/http.dart' as http;
import 'weather_model.dart';
import 'forecast_model.dart';
import 'weather/weather_alert.dart';

class WeatherService {
  Future<Weather> fetchWeather(String city) async {
  final response = await http.get(
    Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$city&appid=91e819be8a1a3c77ca09aec6a80eb5fe&units=metric'),
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return Weather.fromJson(json);
  } else {
    throw Exception('Failed to load weather');
  }
}
  Future<Map<String, double>> getCoordinatesFromCity(String city) async {
    final url = Uri.parse(
      'http://api.openweathermap.org/geo/1.0/direct?q=$city&limit=1&appid=91e819be8a1a3c77ca09aec6a80eb5fe',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        final lat = data[0]['lat'] as double;
        final lon = data[0]['lon'] as double;
        return {'lat': lat, 'lon': lon};
      } else {
        throw Exception('City not found');
      }
    } else {
      throw Exception('Failed to get coordinates');
    }
  }

  Future<List<WeatherAlert>> fetchWeatherAlerts(double lat, double lon) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&appid=91e819be8a1a3c77ca09aec6a80eb5fe&units=metric',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['alerts'] != null) {
        return List<WeatherAlert>.from(
          data['alerts'].map((alert) => WeatherAlert.fromJson(alert)),
        );
      } else {
        return []; // No alerts present
      }
    } else {
      throw Exception('Failed to load weather alerts');
    }
  }

  Future<List<Forecast>> fetch5DayForecast(double lat, double lon) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=91e819be8a1a3c77ca09aec6a80eb5fe&units=metric',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> list = data['list'];
      return list.map((json) => Forecast.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load forecast');
    }
  }


  Future<Weather> fetchWeatherByCoordinates(double lat, double lon) async {
  final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=91e819be8a1a3c77ca09aec6a80eb5fe&units=metric');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return Weather.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load weather');
  }
}

}
