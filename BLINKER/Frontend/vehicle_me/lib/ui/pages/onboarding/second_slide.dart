import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vehicle_me/domain/models/user.dart';
import 'package:vehicle_me/domain/models/vehicle.dart';
import 'package:vehicle_me/domain/state_management/onboarding/onboarding_bloc.dart';
import 'package:vehicle_me/data/repositories/user/user_service_contract.dart';
import 'package:vehicle_me/ui/widgets/shared/customDropDown.dart';

class OnboardingSecondSlide extends StatefulWidget {
  final String carID;

  OnboardingSecondSlide({required this.carID});

  @override
  _OnboardingSecondSlideState createState() => _OnboardingSecondSlideState();
}
class _OnboardingSecondSlideState extends State<OnboardingSecondSlide> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  String _selectedGender = '';

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (context.read<OnboardingBloc>().state is OnboardingSuccess) {
          User user = (state as OnboardingSuccess).user;
          Navigator.pushReplacementNamed(context, 'third_slide', arguments: user);
        }
        else if (context.read<OnboardingBloc>().state is OnboardingError) {
          final errorState = context.read<OnboardingBloc>().state as OnboardingError;
          print('Error: ${errorState.message}');
        }
        else{print('Failed');}
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Onboarding - Slide 2'),
        ),
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email:'),
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 12.0),
                TextField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: 'First Name:'),
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 12.0),
                TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: 'Last Name:'),
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 12.0),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password:'),
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 12.0),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(labelText: 'Confirm Password:'),
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 12.0),
                TextField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(labelText: 'Phone Number:'),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 12.0),
                DropdownCustom(
                    title: 'Gender', items: ['Male', 'Female', 'Other']),
                SizedBox(height: 24.0),
                ElevatedButton(
                    onPressed: () {
                      var userData = _checkInputs(widget.carID);
                      if (userData is String) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              userData,
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        );
                      } else {
                        context.read<OnboardingBloc>().add(
                            RegisterEvent(userData));


                      }
                    },
                    child: Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _checkInputs(String carID) {
    // Returns a Map of the user's data if valid, otherwise returns an error message String.
    String email = _emailController.text;
    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;
    String phoneNumber = _phoneNumberController.text;
    String gender = _selectedGender;

    var error = '';
    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        phoneNumber.isEmpty ||
        firstName.isEmpty ||
        lastName.isEmpty) {
      error = 'Please fill all fields.';
      return error;
    }

    if (password != confirmPassword) {
      error = 'Passwords do not match.';
      return error;
    }

    final Map<String, dynamic> formData = <String, dynamic>{
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'password': password,
      'phone': phoneNumber,
      'gender': gender,
      'vehicle': Vehicle(carId: carID),
      'last_seen': DateTime.now().toIso8601String(),
      "photo_url": 'photo_url'
    };

    return (formData);
  }
}
