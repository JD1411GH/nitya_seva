import 'package:nitya_seva/firebase.dart';

class SevaTicket {
  final DateTime timestamp = DateTime.now();
  final int amount;
  final String mode;
  final int ticket;

  SevaTicket(this.amount, this.mode, this.ticket);
}

class SevaSlot {
  final DateTime timestamp = DateTime.now();
  final String sevakarta;
  final List<SevaTicket> sevaTickets = [];

  SevaSlot(this.sevakarta);

  void addSevaTicket(SevaTicket ticket) {
    sevaTickets.add(ticket);
  }

  void removeSevaTicket(DateTime timestamp) {
    sevaTickets.removeWhere((ticket) => ticket.timestamp == timestamp);
  }

  void updateSevaTicket(DateTime timestamp, SevaTicket ticket) {
    final index =
        sevaTickets.indexWhere((ticket) => ticket.timestamp == timestamp);
    sevaTickets[index] = ticket;
  }
}

class Record {
  static final Record _instance = Record._internal();
  List<SevaSlot> sevaSlots = [];

  // Private constructor
  Record._internal();

  // Public factory constructor to return the instance
  factory Record() {
    return _instance;
  }

  void addSevaSlot(SevaSlot slot) {
    sevaSlots.add(slot);

    // write to FB
  }

  void removeSevaSlot(DateTime timestamp) {
    sevaSlots.removeWhere((slot) => slot.timestamp == timestamp);
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
}
