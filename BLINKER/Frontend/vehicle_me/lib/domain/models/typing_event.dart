enum Typing { start, stop }

extension TypingParsing on Typing {
  String value() {
    //returns Typing String
    return this
        .toString()
        .split(".")
        .last;
  }

  static Typing fromString(String? event) {
    //returns Typing value
    return Typing.values.firstWhere((element) =>
    element.value() == event);
  }
}
class TypingEvent {
  String? get id => _id;
  final String sender;
  final String recipient;
  final Typing event;
  String? _id;
  String? chatId;


  TypingEvent({
    required this.chatId,
    required this.sender,
    required this.recipient,
    required this.event,
  });


  TypingEvent.empty()
      : sender = '',
        recipient = '',
        event = Typing.start;


  factory TypingEvent.fromJson(Map<String, dynamic> json) {
    return TypingEvent(
      sender: json['messageID'],
      recipient: json['recipient'] ,
      event: TypingParsing.fromString(json['status']),
      chatId: json['chatId'],
    ).._id = json['_id']; //TypingEvent
  }

  Map<String, dynamic> toJson() => {
    'chatId' : chatId,
    'sender': sender,
    'recipient': recipient,
    'event': event.value(),
  };
}

