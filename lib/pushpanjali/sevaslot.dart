class SevaTicket {
  final DateTime timestampTicket;
  final DateTime timestampSlot; // Added new member
  final int amount;
  final String mode;
  final int ticket;
  final String user;
  final String remarks;

  SevaTicket({
    required this.amount,
    required this.mode,
    required this.ticket,
    required this.user,
    required this.timestampTicket,
    required this.timestampSlot, // Initialize new member
    required this.remarks,
  });

  factory SevaTicket.fromJson(Map<String, dynamic> json) {
    return SevaTicket(
      timestampTicket: DateTime.parse(json['timestampTicket'] as String),
      timestampSlot:
          DateTime.parse(json['timestampSlot'] as String), // Parse new member
      amount: json['amount'],
      mode: json['mode'],
      ticket: json['ticket'],
      user: json['user'],
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestampTicket': timestampTicket.toIso8601String(),
      'timestampSlot': timestampSlot.toIso8601String(), // Serialize new member
      'amount': amount,
      'mode': mode,
      'ticket': ticket,
      'user': user,
      'remarks': remarks,
    };
  }
}

class PushpanjaliSlot {
  DateTime timestampSlot;
  final String title;
  final String sevakartaSlot;

  PushpanjaliSlot(
      {required this.timestampSlot,
      required this.title,
      required this.sevakartaSlot});

  // Convert a PushpanjaliSlot instance to a Map
  Map<String, dynamic> toJson() {
    return {
      'timestampSlot': timestampSlot.toIso8601String(),
      'title': title,
      'sevakartaSlot': sevakartaSlot,
    };
  }

  // Create a PushpanjaliSlot instance from a Map
  factory PushpanjaliSlot.fromJson(Map<String, dynamic> json) {
    return PushpanjaliSlot(
      timestampSlot: DateTime.parse(json['timestampSlot'] as String),
      title: json['title'] as String,
      sevakartaSlot: json['sevakartaSlot'] as String,
    );
  }
}
