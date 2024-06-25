class GroupChat {
  String? get id => _id;
  final String name;
  final String created_by;
  List<String> members;
  String? _id;

  GroupChat({
    required this.created_by,
    required this.name,
    required this.members,
  });

  Map<String, dynamic> toJson() => {
    'id': _id,
    'createdBy': created_by,
    'name': name,
    'members': members,
  };

  factory GroupChat.fromJson(Map<String, dynamic> json) {
    return GroupChat(
      created_by: json['createdBy'] ?? '',
      name: json['name'] ?? '',
      members: List<String>.from(json['members'] ?? []),
    ).._id = json['id'];
  }
}