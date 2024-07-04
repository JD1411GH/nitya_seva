class Entry {
  final String time;
  final String author;
  final double amount;
  final String mode;
  final String ticket;

  Entry({
    required this.time,
    required this.author,
    required this.amount,
    required this.mode,
    required this.ticket,
  });

  Map<String, dynamic> toJson() => {
        'time': time,
        'author': author,
        'amount': amount,
        'mode': mode,
        'ticket': ticket,
      };

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      time: json['time'],
      author: json['author'],
      amount: json['amount'],
      mode: json['mode'],
      ticket: json['ticket'],
    );
  }
}
