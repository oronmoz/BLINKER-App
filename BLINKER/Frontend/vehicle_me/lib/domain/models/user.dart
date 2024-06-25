import 'vehicle.dart';

class User {
  String? get id => _id;
  final String email;
  final String first_name;
  final String last_name;
  final String password;
  final Vehicle vehicle;
  final String phone;
  final String gender;
  String? photo_url;
  final bool is_active;
  final String last_seen;
  String? _id;

  User({
    String? id,
    required this.email,
    required this.first_name,
    required this.last_name,
    required this.password,
    required this.vehicle,
    required this.phone,
    required this.gender,
    required this.is_active,
    required this.last_seen,
    this.photo_url,
  }) : _id = id;


  // Named constructor for creating an empty object
  User.empty()
      : email = '',
        first_name = '',
        last_name = '',
        password = '',
        vehicle = Vehicle(carId: ''),
        phone = '',
        gender = '',
        is_active = true,
        last_seen = DateTime.now().toIso8601String(),
        photo_url = '',
        _id = null;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      password: json['password'],
      vehicle: Vehicle.fromJson(json['vehicle']),
      phone: json['phone'],
      gender: json['gender'],
      photo_url: json['photo_url'] ?? '',
      // Check for null
      is_active: json['is_active'],
      // Default value for boolean
      last_seen: json['last_seen'],
    ).._id = json['_id'];
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'first_name': first_name,
        'last_name': last_name,
        'password': password,
        'vehicle': vehicle.toJson(),
        'phone': phone,
        'gender': gender,
        'last_seen': last_seen,
        'is_active': is_active,
        'photo_url': photo_url,
        '_id': _id,
      };
}
