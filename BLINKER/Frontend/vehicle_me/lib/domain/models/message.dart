

class Message {
  String? get id => _id;
  final String sender;
  final String recipient;
  final String time_stamp;
  late final String contents;
  String? _id;
  String? group_id;

    Message({
      required this.sender,
      required this.recipient,
      required this.time_stamp,
      required this.contents,
      this.group_id
    });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      sender: json['sender'],
      recipient: json['recipient'],
      time_stamp: (json['time_stamp']),
      contents: json['contents'],
      group_id: json['group_id'],
      ).._id = json['_id']; //Message
    }

  Map<String, dynamic> toJson() => {
    'sender': sender,
    'recipient': recipient,
    'time_stamp': time_stamp,
    'contents': contents,
    'group_id': group_id,
    };
}

