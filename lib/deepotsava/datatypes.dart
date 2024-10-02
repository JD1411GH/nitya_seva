class DeepamStock {
  final int preparedLamps;
  final int unpreparedLamps;
  final int wicks;
  final int gheePackets;
  final int oilCans;

  DeepamStock({
    required this.preparedLamps,
    required this.unpreparedLamps,
    required this.wicks,
    required this.gheePackets,
    required this.oilCans,
  });

  factory DeepamStock.fromJson(Map<String, dynamic> json) {
    return DeepamStock(
      preparedLamps: json['preparedLamps'] as int,
      unpreparedLamps: json['unpreparedLamps'] as int,
      wicks: json['wicks'] as int,
      gheePackets: json['gheePackets'] as int,
      oilCans: json['oilCans'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preparedLamps': preparedLamps,
      'unpreparedLamps': unpreparedLamps,
      'wicks': wicks,
      'gheePackets': gheePackets,
      'oilCans': oilCans,
    };
  }
}

class DeepamSale {
  final DateTime timestamp;
  final String stall; // this will perhaps help during debugging
  final String user;
  final int rate;
  final int count;
  final String paymentMode;
  final bool plate; // new parameter

  DeepamSale({
    required this.timestamp,
    required this.stall,
    required this.user,
    required this.rate,
    required this.count,
    required this.paymentMode,
    required this.plate, // new parameter
  });

  factory DeepamSale.fromJson(Map<String, dynamic> json) {
    return DeepamSale(
      timestamp: DateTime.parse(json['timestamp'] as String),
      stall: json['stall'] as String,
      user: json['user'] as String,
      rate: json['rate'] as int,
      count: json['count'] as int,
      paymentMode: json['paymentMode'] as String,
      plate: json['plate'] as bool, // new parameter
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'stall': stall,
      'user': user,
      'rate': rate,
      'count': count,
      'paymentMode': paymentMode,
      'plate': plate, // new parameter
    };
  }
}
