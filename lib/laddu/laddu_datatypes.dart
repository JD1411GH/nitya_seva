import 'dart:convert';

class LadduStock {
  final DateTime timestamp;
  final String user;
  final int count;

  LadduStock(
      {required this.timestamp, required this.user, required this.count});

  // Convert a LadduStock instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'user': user,
      'count': count,
    };
  }

  // Create a LadduStock instance from a JSON map
  factory LadduStock.fromJson(Map<String, dynamic> json) {
    return LadduStock(
      timestamp: DateTime.parse(json['timestamp']),
      user: json['user'],
      count: json['count'],
    );
  }
}
