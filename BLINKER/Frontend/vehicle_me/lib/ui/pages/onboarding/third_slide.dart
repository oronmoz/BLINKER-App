import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/state_management/onboarding/onboarding_bloc.dart';

class OnboardingThirdSlide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {

      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Onboarding - Slide 3'),
        ),
        body: Center(
          child: BlocBuilder<OnboardingBloc, OnboardingState>(
            builder: (context, state) {
              final bloc = context.read<OnboardingBloc>();

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Successful Registration!'),
                  Text('Welcome Aboard.'),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, 'home');
                    },
                    child: Text('Go to Blinker'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
