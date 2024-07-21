import 'package:nitya_seva/fb.dart';
import 'package:nitya_seva/toaster.dart';

class SevaTicket {
  final DateTime timestamp;
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
    required this.timestamp,
    required this.note,
  });

  factory SevaTicket.fromJson(Map<String, dynamic> json) {
    return SevaTicket(
      timestamp: DateTime.parse(json['timestamp']),
      amount: json['amount'],
      mode: json['mode'],
      ticket: json['ticket'],
      user: json['user'],
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
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

  void addSevaSlot(DateTime timestampSlot, SevaSlot slot) {
    sevaSlots.add(slot);
    sevaSlots.sort((a, b) => b.timestampSlot.compareTo(a.timestampSlot));

    FB().addSevaSlot(timestampSlot.toIso8601String(), slot.toJson());

    if (callbacks != null) {
      callbacks!.onChange();
    }
  }

  void removeSevaSlot(DateTime timestampSlot) {
    sevaSlots.removeWhere((slot) => slot.timestampSlot == timestampSlot);
    sevaSlots.sort((a, b) => b.timestampSlot.compareTo(a.timestampSlot));

    FB().removeSevaSlot(timestampSlot.toIso8601String());

    if (callbacks != null) {
      callbacks!.onChange();
    }

    Toaster().info("Slot removed");
  }

  void addSevaTicket(DateTime timestampSlot, SevaTicket ticket) {
    FB().addSevaTicket(timestampSlot.toIso8601String(),
        ticket.timestamp.toIso8601String(), ticket.toJson());
  }

  // SevaSlot getSevaSlot(String timestampSlot) {
  //   return sevaSlots.firstWhere(
  //       (slot) => slot.timestampSlot.toIso8601String() == timestampSlot);
  // }

  void registerCallbacks(RecordCallbacks callbacks) {
    this.callbacks = callbacks;
  }
}

class RecordCallbacks {
  void Function() onChange;

  RecordCallbacks({required this.onChange});
}
