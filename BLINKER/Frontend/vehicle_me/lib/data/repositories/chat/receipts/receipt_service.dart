import 'package:vehicle_me/domain/models/user.dart';
import '../../../../domain/models/receipt.dart';
import 'dart:async';

abstract class IReceiptService {

  connect(User user);

  dispose();

  Stream<Receipt> receipts(User user);

  Future<String> send(Receipt receipt);
}
