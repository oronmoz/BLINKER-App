import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vehicle_me/composition_root.dart';
import 'package:vehicle_me/domain/models/forum.dart';
import '../../domain/models/chat.dart';
import '../../domain/models/user.dart';


/// Handles the navigation and routing within the application.
///
/// This class is responsible for defining the routes and composing the corresponding UI screens.
class UiRouter {
  final storage = const FlutterSecureStorage();
  static int launchCount = 0;
  // Constructor to initialize activeUser
  UiRouter();

  /// Generates the route based on the provided [RouteSettings].
  ///
  /// Returns the corresponding [MaterialPageRoute] for the given route settings.
  RouteFactory get onGenerateRoute => (RouteSettings routeSettings) {

    // Define the routes and their corresponding UI compositions
    switch (routeSettings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) {
                // Get necessary data from Composition Root
                return CompositionRoot.composeOnboardingFirstSlide();
              },
            );
          case 'second_slide':
            String carID = routeSettings.arguments as String;
            return MaterialPageRoute(
              builder: (_) {
                // Get necessary data from Composition Root
                return CompositionRoot.composeOnboardingSecondSlide(carID);
              },
            );
          case 'third_slide':
            return MaterialPageRoute(
              builder: (_) {
                User user = routeSettings.arguments as User;
                saveUser(user);

                // Get necessary data from Composition Root
                return CompositionRoot.composeOnboardingThirdSlide(user);
              },
            );
          case 'sign-in':
            return MaterialPageRoute(
              builder: (_) {
                // Get necessary data from Composition Root
                return CompositionRoot.composeLoginScreenUI();
              },
            );
          case 'home':
            return MaterialPageRoute(
              builder: (_) {
                User user = routeSettings.arguments as User;
                // Get necessary data from Composition Root
                return CompositionRoot.composeHomeUI(user);
              },
            );
          case 'message_thread':
            final args = routeSettings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => CompositionRoot.composeMessageThreadUI(
                args['receivers'],
                args['me'] as User,
                args['chat'] as Chat,
              ),
            );
          case 'parking':
            return MaterialPageRoute(
              builder: (_) {
                // Get necessary data from Composition Root
                return CompositionRoot.composeLocateParking();
              },
            );
          case 'services':
            return MaterialPageRoute(
              builder: (_) {
                return FutureBuilder<String>(
                  future: routeSettings.arguments as Future<String>,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        return Scaffold(
                          body: Center(
                            child: Text('Error: ${snapshot.error}'),
                          ),
                        );
                      }
                      String auth = snapshot.data ?? '';
                      return CompositionRoot.composeLocateServices(auth);
                    } else {
                      return Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                  },
                );
              },
            );
          case 'my_car':
            return MaterialPageRoute(
              builder: (_) {
                final arguments = routeSettings.arguments;
                if (arguments != null && arguments is Map) {
                  User activeUser = arguments['user'];
                  String last_test_date = arguments['last_test_date'];
                  String test_expiration_date = arguments['test_expiration_date'];
                  String on_road_date = arguments['on_road_date'];
                  return CompositionRoot.composeMyCarUI(activeUser, last_test_date, test_expiration_date, on_road_date);
                }
                else{
                  User activeUser = getUser() as User;
                  return CompositionRoot.composeMyCarUI(activeUser, 'error', 'error', 'error');
                }
              },
            );
          case 'profile_page':
            return MaterialPageRoute(
              builder: (_) {
                User user = routeSettings.arguments as User;

                // Get necessary data from Composition Root
                return CompositionRoot.composeProfilePageUI(user);
              },
            );
          case 'post_detail_page':
            return MaterialPageRoute(
              builder: (context) {
                final arguments = routeSettings.arguments;
                if (arguments != null && arguments is Map) {
                  ForumPost post = arguments['post'];
                  User user = arguments['user'];
                  return CompositionRoot.composePostDetailPageUI(user, post);
                } else {
                  return Scaffold(
                    appBar: AppBar(
                      title: Text('Error'),
                    ),
                    body: Center(
                      child: Text('Required arguments are missing.'),
                    ),
                  );
                }
              },
            );
          default:
            return null;
        }
      };

  void dispose() {
  }
}
