import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:vehicle_me/domain/models/user.dart';
import 'package:vehicle_me/domain/models/user_login.dart';
import 'package:vehicle_me/domain/state_management/auth/auth_bloc.dart';
import '../../../domain/models/vehicle.dart';
import 'package:vehicle_me/data/repositories/user/user_service_contract.dart';

/// Provides user-related operations.
///
/// This class is responsible for handling user registration, login, disconnection,
/// and fetching user information.
class UserService implements IUserService {
  final String baseURL;

  /// Constructs a new [UserService] instance.
  ///
  /// [baseURL] - The base URL of the API.
  UserService(this.baseURL);

  /// Registers a new user.
  ///
  /// [userData] - The user data to be registered.
  ///
  /// Returns a map with either the registered [User] data or an error message.
  @override
  Future<Map<String, dynamic>> registerUser(
      Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseURL/users/register'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = User.fromJson(data);
        return {'data': userData}; // Successful result
      } else {
        if (response.headers['content-type']?.contains('application/json') ??
            false) {
          final Map<String, dynamic> errorJson = jsonDecode(response.body);
          final String errorMessage = errorJson['error']['message'];
          return {'error': "An error occurred: $errorMessage"};
        }
        return {'error': "An unknown error occurred. Please try again later."};
      }
    } catch (e) {
      return {'error': "An error occurred: $e"};
    }
  }


  /// Logs in a user.
  ///
  /// [email] - The email of the user.
  /// [password] - The password of the user.
  ///
  /// Returns the authentication token if the login is successful, otherwise `null`.
  @override
  Future<String?> login(String email, String password) async {
    final UserLogin userLogin =
        UserLogin(email: email, password: password, isActive: true);
    final response = await http.post(
      Uri.parse('$baseURL/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userLogin.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String authToken = responseData['access_token'];
      return authToken;
    } else {
      // Error response
      return null;
    }
  }

  /// Disconnects a user.
  ///
  /// [user] - The user to be disconnected.
  ///
  /// Returns `null` if the disconnection is successful, otherwise an error message.
  @override
  Future<String?>? disconnect(User user) async {
    try {
      final url = Uri.parse('$baseURL/users/${user.id}');
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'active': false, 'last_seen': DateTime.now().toIso8601String()}),
      );
      if (response.statusCode != 200) {
        // Error response
        if (response.headers['content-type']?.contains('application/json') ??
            false) {
          // Response body contains JSON error details
          final Map<String, dynamic> errorJson = jsonDecode(response.body);
          final String errorMessage = errorJson['error']['message'];
          // Return the error message
          return ("An error occurred: $errorMessage");
        }
        throw Exception('Failed to disconnect user');
      }
    } catch (e) {
      return ("An error occurred: $e");
    }
    return null;
  }

  /// Fetches the list of active users.
  ///
  /// [token] - The authentication token.
  ///
  /// Returns the list of active [User] instances.
  @override
  dynamic online(String token) async {
    try {
      String auth = token.toString();
      final response = await http.get(
        Uri.parse("$baseURL/users/user/profile"),
        headers: {'Authorization': 'Bearer $auth'},
      );

      if (response.statusCode == 200) {
        // If the call to the API was successful, parse the JSON
        List<dynamic> userListJson = json.decode(response.body);

        // Map JSON array to List<User>
        List<User> userList =
            userListJson.map((item) => User.fromJson(item)).toList();
        return userList;
      } else {
        // If the API call was not successful, throw an exception or handle the error as needed
        throw Exception('Failed to load active users');
      }
    } catch (e) {
      // Catch any potential errors that may occur during the HTTP call
      return ('Failed to connect to the API: $e');
    }
  }

  // @override
  // Future<List<String>> fetchEmailsByCarIds(List<String> carIds) async {
  //   final url = Uri.parse('$baseURL/users/users_by_car');
  //
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({'carIds': carIds}),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> data = jsonDecode(response.body);
  //       final List<dynamic> emails = data['emails'];
  //       return emails.cast<String>();
  //     } else {
  //       // Error handling
  //       String errorMessage = "An error occurred. Please try again later.";
  //       if (response.headers['content-type']?.contains('application/json') == true) {
  //         final Map<String, dynamic> errorJson = jsonDecode(response.body);
  //         errorMessage = errorJson['detail'] ?? errorMessage;
  //       }
  //       throw Exception(errorMessage);
  //     }
  //   } catch (e) {
  //     throw Exception("An error occurred: $e");
  //   }
  // }


  /// Fetches the list of users by car IDs.
  ///
  /// [carIds] - The list of car IDs.
  /// [token] - The authentication token.
  ///
  /// Returns the list of [User] instances corresponding to the provided car IDs.
  @override
  Future<List<User>> fetchUsersByCarIds(List<String> carIds, String token) async {
    final url = Uri.parse('$baseURL/users/users_by_car');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'carIds': carIds}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => User.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception("An error occurred: $e");
    }
  }


  /// Fetches the list of users by email addresses.
  ///
  /// [emails] - The list of email addresses.
  /// [token] - The authentication token.
  ///
  /// Returns the list of [User] instances corresponding to the provided email addresses.
  @override
  Future<List<User>> fetchUsersByEmails(List<String> emails, String token) async {
    final url = Uri.parse('$baseURL/users/users_by_emails');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'emails': emails}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => User.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception("An error occurred: $e");
    }
  }


  /// Fetches the user information by email.
  ///
  /// [auth] - The authentication token.
  ///
  /// Returns a map with either the user data or an error message.
  @override
  Future<Map<String, dynamic>> fetchUserByEmail(String auth) async {
    final url = Uri.parse('$baseURL/users/fetch_login_emails');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $auth',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else {
        throw Exception('Failed to load user profile: ${response.statusCode}');
      }
    } catch (e) {
      return {'error': "An error occurred: $e"};
    }
  }


  /// Fetches the vehicle information.
  ///
  /// [carID] - The ID of the car.
  /// [authToken] - The authentication token.
  ///
  /// Returns a map with the vehicle information or an error message.
  @override
  Future<Map<String, dynamic>> fetchVehicleInfo(
      String carID, String authToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseURL/services/vehicle_info/$carID'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> strings = json.decode(response.body);
        if (strings.containsKey('last_test_date') &&
            strings.containsKey('test_expiration_date') &&
            strings.containsKey('on_road_date')) {
          return strings;
        } else {
          return {
            'error': 'Required fields missing in vehicle info response'
          };
        }
      } else {
        return {
          'error': 'Failed to load vehicle info: ${response.statusCode} - ${response.body}'
        };
      }
    } catch (error) {
      return {
        'error': 'Error fetching vehicle info: $error'
      };
    }
  }
}
