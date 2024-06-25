import 'package:vehicle_me/domain/models/user.dart';
import '../../../../domain/models/typing_event.dart';

abstract class ITypingNotification {
  Future<bool?> send({required List<TypingEvent> events});
  Stream<TypingEvent> subscribe(User user, List<String> userIds);
  void dispose();
}