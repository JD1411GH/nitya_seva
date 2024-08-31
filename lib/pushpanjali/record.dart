import 'package:garuda/fb.dart';
import 'package:garuda/toaster.dart';
import 'package:garuda/pushpanjali/sevaslot.dart';

class Record {
  static final Record _instance = Record._internal();
  List<SevaSlot> sevaSlots = [];
  Map<DateTime, List<SevaTicket>> sevaTickets = {}; // to FB from List to Map
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
        deleteSevaSlot(slot.timestampSlot);
        break;
      case 'UPDATE_SEVA_SLOT':
        break;
      default:
        Toaster().error('Unknown change type: $changeType');
    }
  }

  void onSevaTicketChange(String changeType, dynamic sevaTicketMap) {
    switch (changeType) {
      case 'ADD_SEVA_TICKET':
        sevaTicketMap.forEach((dynamic timestampTicket, dynamic ticketData) {
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
        sevaTicketMap.forEach((dynamic timestampTicket, dynamic ticketData) {
          SevaTicket ticket =
              SevaTicket.fromJson(Map<String, dynamic>.from(ticketData));

          DateTime timestampSlot = ticket.timestampSlot;
          DateTime timestampTicket = ticket.timestampTicket;

          deleteSevaTicket(ticket.timestampSlot, ticket.timestampTicket);
        });
        break;
      case 'UPDATE_SEVA_TICKET':
        bool flagOnce = false;
        sevaTicketMap.forEach((dynamic timestampTicket, dynamic ticketData) {
          SevaTicket ticket =
              SevaTicket.fromJson(Map<String, dynamic>.from(ticketData));

          DateTime timestampSlot = ticket.timestampSlot;

          if (flagOnce == false) {
            sevaTickets[timestampSlot]!.clear();
            flagOnce = true;
          }

          if (sevaTickets.containsKey(ticket.timestampSlot)) {
            if (sevaTickets[ticket.timestampSlot]!.any((element) =>
                element.timestampTicket == ticket.timestampTicket)) {
              // "Ticket already exists"
              return;
            }
          }

          addSevaTicket(ticket.timestampSlot, ticket);
        });
        Toaster().info("Ticket updated");
        break;

      default:
        Toaster().error('Unknown change type: $changeType');
    }
  }

  void addSevaSlot(DateTime timestampSlot, SevaSlot slot) {
    sevaSlots.add(slot);
    sevaSlots.sort((a, b) => b.timestampSlot.compareTo(a.timestampSlot));

    FB().addSevaSlot(timestampSlot, slot.toJson());

    if (callbacks != null && callbacks!.onSlotChange != null) {
      callbacks!.onSlotChange!();
    }
  }

  void deleteSevaSlot(DateTime timestampSlot) {
    FB().deleteSevaSlot(timestampSlot);

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

  void editSevaTicket(DateTime timestampSlot, SevaTicket ticket) {
    if (sevaTickets[timestampSlot] == null) {
      Toaster().error("No tickets found for the slot");
      return;
    }

    List<SevaTicket> tickets = sevaTickets[timestampSlot]!;
    int index = tickets.indexWhere(
        (element) => element.timestampTicket == ticket.timestampTicket);

    if (index == -1) {
      Toaster().error("Ticket not found");
      return;
    }

    sevaTickets[timestampSlot]![index] = ticket;
    sevaTickets[timestampSlot]!
        .sort((a, b) => b.timestampTicket.compareTo(a.timestampTicket));

    if (callbacks != null && callbacks!.onTicketChange != null) {
      callbacks!.onTicketChange!();
    }

    FB().editSevaTicket(timestampSlot.toIso8601String(),
        ticket.timestampTicket.toIso8601String(), ticket.toJson());
  }

  void deleteSevaTicket(DateTime timestampSlot, DateTime timestampTicket) {
    FB().deleteSevaTicket(
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

  Future<void> refreshSevaSlots() async {
    sevaSlots = await FB().readSevaSlots();
    sevaSlots.sort((a, b) => b.timestampSlot.compareTo(a.timestampSlot));
  }

  Future<void> refreshSevaTickets(DateTime timestampSlot) async {
    sevaTickets[timestampSlot] = await FB().readSevaTickets(timestampSlot);
    sevaTickets[timestampSlot]!
        .sort((a, b) => b.timestampTicket.compareTo(a.timestampTicket));
  }
}

class RecordCallbacks {
  void Function()? onSlotChange;
  void Function()? onTicketChange;

  RecordCallbacks({this.onSlotChange, this.onTicketChange});
}
