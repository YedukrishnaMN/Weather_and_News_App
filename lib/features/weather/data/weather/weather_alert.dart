class WeatherAlert {
  final String senderName;
  final String event;
  final String description;
  final int start;
  final int end;

  WeatherAlert({
    required this.senderName,
    required this.event,
    required this.description,
    required this.start,
    required this.end,
  });

  factory WeatherAlert.fromJson(Map<String, dynamic> json) {
    return WeatherAlert(
      senderName: json['sender_name'] ?? 'Unknown Sender',
      event: json['event'] ?? 'Unknown Event',
      description: json['description'] ?? '',
      start: json['start'] ?? 0,
      end: json['end'] ?? 0,
    );
  }
}
