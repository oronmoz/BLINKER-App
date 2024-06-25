enum ReceiptStatus { sent, delivered, read }

extension ReceiptParsing on ReceiptStatus {
  String value() {
    //returns ReceiptStatus String
    return toString().split(".").last;
  }

  static ReceiptStatus fromString(String status) {
    //returns ReceiptStatus value
    return ReceiptStatus.values
        .firstWhere((element) => element.value() == status);
  }
}

class Receipt {
  String get id => _id;
  final String messageID;
  final String recipient;
  final ReceiptStatus status;

  final String timeStamp;

  late String _id;

  Receipt({
    required this.messageID,
    required this.recipient,
    required this.status,
    required this.timeStamp,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      messageID: json['messageID'],
      recipient: json['recipient'],
      timeStamp: json['timeStamp'],
      status: ReceiptParsing.fromString(json['status']),
    ).._id = json['_id']; //Receipt
  }

  Map<String, dynamic> toJson() => {
        'messageID': messageID,
        'recipient': recipient,
        'timeStamp': timeStamp,
        'status': status,
        '_id': _id,
      };
}
