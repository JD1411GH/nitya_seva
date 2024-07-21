import 'package:nitya_seva/fb.dart';
import 'package:nitya_seva/toaster.dart';

class SevaTicket {
  final DateTime timestampTicket;
  final DateTime timestampSlot; // Added new member
  final int amount;
  final String mode;
  final int ticket;
  final String user;
  final String note;

  SevaTicket({
    required this.amount,
    required this.mode,
    required this.ticket,
    required this.user,
    required this.timestampTicket,
    required this.timestampSlot, // Initialize new member
    required this.note,
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
      note: json['note'],
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
      'note': note,
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

class Record {
  static final Record _instance = Record._internal();
  List<SevaSlot> sevaSlots = [];
  // List<Map<DateTime, SevaTicket>> sevaTickets = [];
  Map<DateTime, List<SevaTicket>> sevaTickets = {};
  RecordCallbacks? callbacks;

  // Private constructor
  Record._internal();

  // Public factory constructor to return the instance
  factory Record() {
    return _instance;
  }

  Future<void> init() async {
    // register callback for any change in seva slot - add, remove, update
    FB().listenForSevaSlotChange(FBCallbacks(onChange: onSevaSlotChange));
    FB().listenForSevaTicketChange(FBCallbacks(onChange: onSevaTicketChange));
  }

  void onSevaSlotChange(String changeType, dynamic sevaSlot) {
    switch (changeType) {
      case 'ADD_SEVA_SLOT':
        SevaSlot slot = SevaSlot.fromJson(Map<String, dynamic>.from(sevaSlot));

        if (sevaSlots
            .any((element) => element.timestampSlot == slot.timestampSlot)) {
          // "Slot already exists"
          return;
        }

        addSevaSlot(slot.timestampSlot, slot);

        break;
      case 'REMOVE_SEVA_SLOT':
        SevaSlot slot = SevaSlot.fromJson(Map<String, dynamic>.from(sevaSlot));
        removeSevaSlot(slot.timestampSlot);
        break;
      case 'UPDATE_SEVA_SLOT':
        break;
      default:
        Toaster().error('Unknown change type: $changeType');
    }
  }

  void onSevaTicketChange(String changeType, dynamic sevaTicket) {
    switch (changeType) {
      case 'ADD_SEVA_TICKET':
        sevaTicket.forEach((dynamic timestampTicket, dynamic ticketData) {
          SevaTicket ticket =
              SevaTicket.fromJson(Map<String, dynamic>.from(ticketData));

          if (sevaTickets.containsKey(ticket.timestampSlot)) {
            if (sevaTickets[ticket.timestampSlot]!.any((element) =>
                element.timestampTicket == ticket.timestampTicket)) {
              // "Ticket already exists"
              return;
            }
          }

          addSevaTicket(ticket.timestampSlot, ticket);
        });

        break;
      case 'REMOVE_SEVA_TICKET':
        break;
      case 'UPDATE_SEVA_TICKET':
        break;
      default:
        Toaster().error('Unknown change type: $changeType');
    }
  }

  void addSevaSlot(DateTime timestampSlot, SevaSlot slot) {
    sevaSlots.add(slot);
    sevaSlots.sort((a, b) => b.timestampSlot.compareTo(a.timestampSlot));

    FB().addSevaSlot(timestampSlot.toIso8601String(), slot.toJson());

    if (callbacks != null && callbacks!.onSlotChange != null) {
      callbacks!.onSlotChange!();
    }
  }

  void removeSevaSlot(DateTime timestampSlot) {
    FB().removeSevaSlot(timestampSlot.toIso8601String());

    sevaSlots.removeWhere((slot) => slot.timestampSlot == timestampSlot);
    sevaSlots.sort((a, b) => b.timestampSlot.compareTo(a.timestampSlot));

    if (callbacks != null && callbacks!.onSlotChange != null) {
      callbacks!.onSlotChange!();
    }

    Toaster().info("Slot removed");
  }

  void addSevaTicket(DateTime timestampSlot, SevaTicket ticket) {
    if (!sevaTickets.containsKey(timestampSlot)) {
      sevaTickets[timestampSlot] =
          []; // Initialize with an empty list if the key doesn't exist
    }
    sevaTickets[timestampSlot]!.add(ticket);

    sevaTickets[timestampSlot]!
        .sort((a, b) => b.timestampTicket.compareTo(a.timestampTicket));

    if (callbacks != null && callbacks!.onTicketChange != null) {
      callbacks!.onTicketChange!();
    }

    FB().addSevaTicket(timestampSlot.toIso8601String(),
        ticket.timestampTicket.toIso8601String(), ticket.toJson());
  }

  void removeSevaTicket(DateTime timestampSlot, DateTime timestampTicket) {
    FB().removeSevaTicket(
        timestampSlot.toIso8601String(), timestampTicket.toIso8601String());

    if (sevaTickets.containsKey(timestampSlot)) {
      sevaTickets[timestampSlot]!
          .removeWhere((ticket) => ticket.timestampTicket == timestampTicket);
      sevaTickets[timestampSlot]!
          .sort((a, b) => b.timestampTicket.compareTo(a.timestampTicket));
    }

    if (callbacks != null && callbacks!.onTicketChange != null) {
      callbacks!.onTicketChange!();
    }

    Toaster().info("Ticket removed");
  }

  void registerCallbacks(RecordCallbacks callbacks) {
    this.callbacks = callbacks;
  }
}

class RecordCallbacks {
  void Function()? onSlotChange;
  void Function()? onTicketChange;

  RecordCallbacks({this.onSlotChange, this.onTicketChange});
}
