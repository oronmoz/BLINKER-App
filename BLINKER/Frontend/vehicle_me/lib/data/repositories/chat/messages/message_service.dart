import 'package:vehicle_me/domain/models/user.dart';
import '../../../../domain/models/message.dart';

abstract class IMessageService {
  Future<void> connect(User user);
  void dispose();
  Stream<Message> messages({required User activeUser});
  Future<List<Message>> send(List<Message> messages);
}



