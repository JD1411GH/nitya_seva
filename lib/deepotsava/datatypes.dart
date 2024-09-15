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
