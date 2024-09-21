import 'package:garuda/pushpanjali/sevaslot.dart';

class LadduStock {
  final DateTime timestamp;
  final String user;
  final String from;
  final int count;

  LadduStock(
      {required this.timestamp,
      required this.user,
      required this.from,
      required this.count});

  // Convert a LadduStock instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'user': user,
      'from': from,
      'count': count,
    };
  }

  // Create a LadduStock instance from a JSON map
  factory LadduStock.fromJson(Map<String, dynamic> json) {
    return LadduStock(
      timestamp: DateTime.parse(json['timestamp']),
      user: json['user'],
      from: json['from'],
      count: json['count'],
    );
  }
}

class LadduServe {
  final DateTime timestamp;
  final String user;
  final List<Map<String, int>> packsPushpanjali;
  final List<Map<String, int>> packsOtherSeva;
  final List<Map<String, int>> packsMisc;
  final String note;
  final String title;
  final int? available;
  final int balance;
  final DateTime? pushpanjaliSlot;

  LadduServe({
    required this.timestamp,
    required this.user,
    required this.packsPushpanjali,
    required this.packsMisc,
    required this.packsOtherSeva,
    required this.note,
    required this.title,
    this.available,
    required this.balance,
    this.pushpanjaliSlot,
  });

  factory LadduServe.fromJson(Map<String, dynamic> json) {
    return LadduServe(
      timestamp: DateTime.parse(json['timestamp']),
      user: json['user'],
      packsPushpanjali: (json['packsPushpanjali'] as List)
          .map((item) => Map<String, int>.from(item))
          .toList(),
      packsMisc: (json['packsMisc'] as List)
          .map((item) => Map<String, int>.from(item))
          .toList(),
      packsOtherSeva: (json['packsOtherSeva'] as List)
          .map((item) => Map<String, int>.from(item))
          .toList(),
      note: json['note'],
      title: json['title'],
      balance: json['balance'],
      pushpanjaliSlot: json['pushpanjaliSlot'] != null
          ? DateTime.parse(json['pushpanjaliSlot'])
          : null,
      available: json['available'] != null ? json['available'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'user': user,
      'packsPushpanjali': packsPushpanjali
          .map((item) =>
              item.map((key, value) => MapEntry(key.toString(), value)))
          .toList(),
      'packsMisc': packsMisc,
      'packsOtherSeva': packsOtherSeva
          .map((item) =>
              item.map((key, value) => MapEntry(key.toString(), value)))
          .toList(),
      'note': note,
      'title': title,
      'balance': balance,
      'pushpanjaliSlot':
          pushpanjaliSlot?.toIso8601String(), // Handle nullable pushpanjaliSlot
      'available': available, // Handle nullable available
    };
  }
}

class LadduReturn {
  final DateTime timestamp;
  final String to;
  final int count;
  final String user;

  LadduReturn(
      {required this.timestamp,
      required this.to,
      required this.count,
      required this.user});

  // Convert a LadduStock instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'to': to,
      'count': count,
      'user': user,
    };
  }

  // Create a LadduStock instance from a JSON map
  factory LadduReturn.fromJson(Map<String, dynamic> json) {
    return LadduReturn(
      timestamp: DateTime.parse(json['timestamp']),
      to: json['to'],
      count: json['count'],
      user: json['user'],
    );
  }
}
