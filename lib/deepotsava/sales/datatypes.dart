class DeepamStock {
  final String stall;
  final DateTime timestamp;
  final String user;

  final int preparedLamps;
  final int unpreparedLamps;
  final int plates;
  final int wicks;
  final int gheePackets;
  final int oilCans;

  DeepamStock({
    required this.timestamp,
    required this.stall,
    required this.user,
    required this.preparedLamps,
    required this.unpreparedLamps,
    required this.plates,
    required this.wicks,
    required this.gheePackets,
    required this.oilCans,
  });

  factory DeepamStock.fromJson(Map<String, dynamic> json) {
    return DeepamStock(
      timestamp: DateTime.parse(json['timestamp'] as String),
      stall: json['stall'] as String,
      user: json['user'] as String,
      preparedLamps: json['preparedLamps'] as int,
      unpreparedLamps: json['unpreparedLamps'] as int,
      plates: json['plates'] as int,
      wicks: json['wicks'] as int,
      gheePackets: json['gheePackets'] as int,
      oilCans: json['oilCans'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'stall': stall,
      'user': user,
      'preparedLamps': preparedLamps,
      'unpreparedLamps': unpreparedLamps,
      'plates': plates,
      'wicks': wicks,
      'gheePackets': gheePackets,
      'oilCans': oilCans,
    };
  }
}

class DeepamSale {
  // default data
  final String stall;
  final DateTime timestamp;
  final String user;

  // config data
  final int costLamp;
  final int costPlate;

  // actual data
  final int count;
  final String paymentMode;
  final int plate; // new parameter

  DeepamSale({
    required this.timestamp,
    required this.stall,
    required this.user,
    required this.costLamp,
    required this.costPlate,
    required this.count,
    required this.paymentMode,
    required this.plate, // new parameter
  });

  factory DeepamSale.fromJson(Map<String, dynamic> json) {
    return DeepamSale(
      timestamp: DateTime.parse(json['timestamp'] as String),
      stall: json['stall'] as String,
      user: json['user'] as String,
      costLamp: json['costLamp'] as int,
      costPlate: json['costPlate'] as int,
      count: json['count'] as int,
      paymentMode: json['paymentMode'] as String,
      plate: json['plate'] as int, // new parameter
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'stall': stall,
      'user': user,
      'costLamp': costLamp,
      'costPlate': costPlate,
      'count': count,
      'paymentMode': paymentMode,
      'plate': plate, // new parameter
    };
  }

  DeepamSale copyWith({
    String? stall,
    DateTime? timestamp,
    String? user,
    int? costLamp,
    int? costPlate,
    int? count,
    String? paymentMode,
    bool? plate,
  }) {
    return DeepamSale(
      stall: stall ?? this.stall,
      timestamp: timestamp ?? this.timestamp,
      user: user ?? this.user,
      costLamp: costLamp ?? this.costLamp,
      costPlate: costPlate ?? this.costPlate,
      count: count ?? this.count,
      paymentMode: paymentMode ?? this.paymentMode,
      plate: this.plate,
    );
  }
}
