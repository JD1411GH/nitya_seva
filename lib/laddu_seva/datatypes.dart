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

class LadduDist {
  final DateTime timestamp;
  final String user;
  final String purpose;
  final int count;
  final String note;

  LadduDist(
      {required this.timestamp,
      required this.user,
      required this.purpose,
      required this.count,
      required this.note});

  // Convert a LadduStock instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'user': user,
      'purpose': purpose,
      'count': count,
      'note': note,
    };
  }

  // Create a LadduStock instance from a JSON map
  factory LadduDist.fromJson(Map<String, dynamic> json) {
    return LadduDist(
      timestamp: DateTime.parse(json['timestamp']),
      user: json['user'],
      purpose: json['purpose'],
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
