import 'package:nitya_seva/fb.dart';

class SevaTicket {
  DateTime timestamp;
  final int amount;
  final String mode;
  final int ticket;

  SevaTicket(this.amount, this.mode, this.ticket) : timestamp = DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'amount': amount,
      'mode': mode,
      'ticket': ticket,
    };
  }

  static SevaTicket fromJson(Map<String, dynamic> json) {
    return SevaTicket(
      json['amount'] as int,
      json['mode'] as String,
      json['ticket'] as int,
    )..timestamp = DateTime.parse(json['timestamp'] as String);
  }
}

class SevaSlot {
  DateTime timestamp;
  final String sevakarta;
  final List<SevaTicket> sevaTickets;

  SevaSlot(this.sevakarta)
      : timestamp = DateTime.now(),
        sevaTickets = [];

  void addSevaTicket(SevaTicket ticket) {
    sevaTickets.add(ticket);
  }

  void removeSevaTicket(DateTime timestamp) {
    sevaTickets.removeWhere((ticket) => ticket.timestamp == timestamp);
  }

  void updateSevaTicket(DateTime timestamp, SevaTicket ticket) {
    final index = sevaTickets.indexWhere((t) => t.timestamp == timestamp);
    if (index != -1) {
      sevaTickets[index] = ticket;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'sevakarta': sevakarta,
      'sevaTickets': sevaTickets.map((ticket) => ticket.toJson()).toList(),
    };
  }

  static SevaSlot fromJson(Map<String, dynamic> json) {
    SevaSlot slot = SevaSlot(
      json['sevakarta'] as String,
    )..timestamp = DateTime.parse(json['timestamp'] as String);

    if (json['sevaTickets'] != null) {
      var ticketsList = json['sevaTickets'] as List;
      slot.sevaTickets.addAll(
        ticketsList.map((ticketJson) =>
            SevaTicket.fromJson(ticketJson as Map<String, dynamic>)),
      );
    }

    return slot;
  }
}

class Record {
  static final Record _instance = Record._internal();
  List<SevaSlot> sevaSlots = []; // unsorted

  // Private constructor
  Record._internal();

  // Public factory constructor to return the instance
  factory Record() {
    return _instance;
  }

  Future<void> init() async {
    // read from FB
    var value = await FB().readSevaSlots();

    for (var element in value) {
      Map<String, dynamic> elementMap =
          Map<String, dynamic>.from(element as Map);
      sevaSlots.add(SevaSlot.fromJson(elementMap));
    }

    sevaSlots.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void addSevaSlot(SevaSlot slot) {
    sevaSlots.add(slot);
    sevaSlots.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    FB().addSevaSlot(slot.toJson());
  }

  void removeSevaSlot(DateTime timestamp) {
    sevaSlots.removeWhere((slot) => slot.timestamp == timestamp);
    sevaSlots.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void display() {
    for (var slot in sevaSlots) {
      print('Sevakarta: ${slot.sevakarta}');
      for (var ticket in slot.sevaTickets) {
        print(
            'Ticket: ${ticket.ticket}, Amount: ${ticket.amount}, Mode: ${ticket.mode}');
      }
    }
  }

  SevaSlot getSevaSlot(String timestamp) {
    return sevaSlots
        .firstWhere((slot) => slot.timestamp.toIso8601String() == timestamp);
  }
}
