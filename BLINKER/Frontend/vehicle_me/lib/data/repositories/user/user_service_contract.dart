import 'package:vehicle_me/domain/models/user.dart';
import 'package:vehicle_me/domain/state_management/auth/auth_bloc.dart';

abstract class IUserService {
  dynamic online(String token);
  Future<String?>? disconnect(User user);
  //dynamic fetch(List<String> ids);

  //fetchEmailsByCarIds();
  Future<Map<String, dynamic>> fetchUserByEmail(String auth);

  Future<String?> login(String email, String password);

  Future<Map<String,dynamic>> registerUser (Map<String,dynamic> userData);

  Future<List<User>> fetchUsersByCarIds(List<String> carIds, String token);
  Future<List<User>> fetchUsersByEmails(List<String> emails, String token);

  Future<Map<String, dynamic>> fetchVehicleInfo(String carID, String authToken);
}