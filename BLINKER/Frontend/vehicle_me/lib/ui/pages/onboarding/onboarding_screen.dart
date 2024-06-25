import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/state_management/onboarding/onboarding_bloc.dart';
import 'package:flutter/material.dart';
import 'first_slide.dart';
import 'second_slide.dart';
import 'third_slide.dart';
// class OnboardingScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<OnboardingBloc, int>(
//       builder: (context, state) {
//         return Scaffold(
//           body: IndexedStack(
//             index: state,
//             children: [
//               OnboardingFirstSlide(),
//               OnboardingSecondSlide(vehicle: vehicle),
//               OnboardingThirdSlide(registrationSuccessful: []),
//             ],
//           ),
//           bottomNavigationBar: BottomNavigationBar(
//             currentIndex: state,
//             onTap: (index) {
//               context.read<OnboardingBloc>().updateSlideIndex(index);
//             },
//             items: [
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.looks_one),
//                 label: 'Slide 1',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.looks_two),
//                 label: 'Slide 2',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.looks_3),
//                 label: 'Slide 3',
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
