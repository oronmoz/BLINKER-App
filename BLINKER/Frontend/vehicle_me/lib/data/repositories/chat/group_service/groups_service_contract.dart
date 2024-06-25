import '../../../../domain/models/group_chat.dart';

abstract class IGroupService {
  Future<GroupChat> create(GroupChat group);

  Stream<GroupChat> groups(String userId);

  void dispose();
}
