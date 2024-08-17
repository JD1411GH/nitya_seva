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

class LadduDist {
  final DateTime timestamp;
  final String user;
  final int count;
  final String note;

  LadduDist(
      {required this.timestamp,
      required this.user,
      required this.count,
      required this.note});

  // Convert a LadduStock instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'user': user,
      'count': count,
      'note': note,
    };
  }

  // Create a LadduStock instance from a JSON map
  factory LadduDist.fromJson(Map<String, dynamic> json) {
    return LadduDist(
      timestamp: DateTime.parse(json['timestamp']),
      user: json['user'],
      count: json['count'],
      note: json['note'],
    );
  }
}

class LadduDistAccumulated {
  final String date;
  int count;
  List<String> users;
  List<String> notes;

  LadduDistAccumulated(
      {required this.date,
      required this.count,
      required this.users,
      required this.notes});

  // Factory constructor to create an instance from a JSON map
  factory LadduDistAccumulated.fromJson(Map<String, dynamic> json) {
    return LadduDistAccumulated(
      date: json['date'],
      count: json['count'],
      users: List<String>.from(json['users']),
      notes: List<String>.from(json['notes']),
    );
  }

  // Method to convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'count': count,
      'users': users,
      'notes': notes,
    };
  }
}
