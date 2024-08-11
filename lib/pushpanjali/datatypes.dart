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
    required this.remarks, // TODO: rename to "remark"
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

class SevaSlot {
  DateTime timestampSlot;
  final String title;
  final String sevakartaSlot;

  SevaSlot(
      {required this.timestampSlot,
      required this.title,
      required this.sevakartaSlot});

  // Convert a SevaSlot instance to a Map
  Map<String, dynamic> toJson() {
    return {
      'timestampSlot': timestampSlot.toIso8601String(),
      'title': title,
      'sevakartaSlot': sevakartaSlot,
    };
  }

  // Create a SevaSlot instance from a Map
  factory SevaSlot.fromJson(Map<String, dynamic> json) {
    return SevaSlot(
      timestampSlot: DateTime.parse(json['timestampSlot'] as String),
      title: json['title'] as String,
      sevakartaSlot: json['sevakartaSlot'] as String,
    );
  }
}
