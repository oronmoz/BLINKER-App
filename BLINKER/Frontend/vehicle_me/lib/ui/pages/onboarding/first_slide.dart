import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vehicle_me/colors.dart';
import 'package:vehicle_me/domain/state_management/onboarding/onboarding_bloc.dart';
import 'package:vehicle_me/ui/widgets/shared/custom_text_field_num.dart';
import '../../widgets/onboarding/logo.dart';
import '../../widgets/shared/background.dart';

class OnboardingFirstSlide extends StatelessWidget {
  String carID = '';

  @override
  Widget build(BuildContext context) {
    final TextEditingController _textController = TextEditingController();

    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (context.read<OnboardingBloc>().state is OnboardingVehicleSuccess) {
          Navigator.pushReplacementNamed(context, 'second_slide',
              arguments: carID);
        }
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Column(children: [
                      Text(
                        'Welcome',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'to',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ]),
                  ),
                  const Logo(),
              Padding(
                padding: EdgeInsets.only(left: 30.0, right: 30.0),
                child: CustomTextFieldNumber.CustomTextFieldNumber(
                  hint: "Enter your vehicle license plate number...",
                  height: 54.0,
                  onChanged: (val) {
                    carID = val;
                  },
                  inputAction: TextInputAction.done,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.only(left: 45.0, right: 45.0),
                child: BlocProvider<OnboardingBloc>.value(
                  value: BlocProvider.of<OnboardingBloc>(context),
                  child: ElevatedButton(
                    onPressed: () {
                      final String checkInput = carID;
                      if (_checkUserInput(checkInput) == false) {
                        final snackBar = SnackBar(
                          content: const Text(
                            'Invalid Number',
                            style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        OnboardingBloc onboardingBloc =
                            BlocProvider.of<OnboardingBloc>(context);
                        onboardingBloc.add(UserInputEvent(carID));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kYellow,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(45.0),
                        side: BorderSide(color: Colors.black54),
                      ),
                    ),
                    child: BlocProvider<OnboardingBloc>.value(
                      value: BlocProvider.of<OnboardingBloc>(context),
                      child: Container(
                        height: 60.0,

                        alignment: Alignment.center,
                        child: Text(
                          'Submit License Plate Number',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                        ),
                      ),
                    ),

                    //onPressed: () {
                    // Get the text input from the TextField
                    //String userInput = _textController.text;
                    // Call a function in the bloc to map this input to a state
                    //bloc.add(UserInputEvent(userInput));
                    //},
                  ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                alignment: Alignment.center,
                child: Text('Already a BLINKER?'),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: BlocProvider<OnboardingBloc>.value(
                  value: BlocProvider.of<OnboardingBloc>(context),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, 'sign-in');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kDarkGray,
                      foregroundColor: kBubblePurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(45.0),
                        side: BorderSide(color: Colors.black54),
                      ),
                    ),
                    child: Container(
                      height: 40.0,
                      width: 90,
                      alignment: Alignment.center,
                      child: Text(
                        'Sign in',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: kCreamLM,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }

  bool _checkUserInput(String userInput) {
    if ((userInput.length != 7) && (userInput.length != 8)) {
      return false;
    }
    final checkIfNum = int.tryParse(userInput);
    return checkIfNum != null;
  }
}
