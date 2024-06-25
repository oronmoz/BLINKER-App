import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vehicle_me/composition_root.dart';
import 'package:vehicle_me/domain/state_management/auth/auth_bloc.dart';
import 'package:vehicle_me/themes.dart';
import 'package:vehicle_me/ui/ui_router/ui_router.dart';
import 'package:vehicle_me/ui/widgets/shared/background_container.dart';
import 'package:vehicle_me/ui/widgets/shared/custom_page_transition_builder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();

  runApp(MyApp());
}

Future<void> setupDependencies() async {
  await CompositionRoot.setup();
}

class MyApp extends StatelessWidget {
  final UiRouter _uiRouter = UiRouter();

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      child: BlocProvider(
        create: (context) => CompositionRoot.getAuthBloc(),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => CompositionRoot.composeLoginScreenUI()),
              );
            }
          },
          child: MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            color: Colors.transparent,
            title: 'BLINKER',
            onGenerateRoute: _uiRouter.onGenerateRoute,
          ),
        ),
      ),
    );
  }

  ThemeData _buildTheme(ThemeData baseTheme) {
    return baseTheme.copyWith(
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final platform in TargetPlatform.values)
            platform: SharedAxisPageTransitionBuilder(),
        },
      ),
    );
  }
}