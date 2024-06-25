import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vehicle_me/colors.dart';
import 'package:vehicle_me/domain/models/user.dart';
import 'package:vehicle_me/domain/state_management/auth/auth_bloc.dart';
import 'package:vehicle_me/domain/state_management/home/chat/message/message_bloc.dart';
import 'package:vehicle_me/domain/state_management/home/forum/forum_bloc.dart';

import 'package:vehicle_me/domain/state_management/home/home_bloc.dart';
import 'package:vehicle_me/domain/state_management/home/parking/parking_bloc.dart';
import 'package:vehicle_me/domain/state_management/home/vehicle_services/locate_service_bloc.dart';
import 'package:vehicle_me/domain/state_management/vehicle_market/auction_bloc.dart';

import 'package:vehicle_me/ui/pages/home/home_router.dart';

import '../../../domain/state_management/home/chat/chats_updater_cubit.dart';
import '../../../domain/state_management/home/chat/groups/group_chat_bloc.dart';
import '../../../domain/state_management/home/chat/receipt/receipt_bloc.dart';
import '../../../domain/state_management/home/chat/typing_notification/typing_notification_bloc.dart';
import '../../../domain/state_management/home/message_thread/message_thread_cubit.dart';
import '../../../themes.dart';
import '../chat/chat.dart';
import '../forum/forum.dart';

import '../../../domain/state_management/home/navigation_bloc.dart';

import '../../widgets/onboarding/logo.dart';
import '../../widgets/shared/custom_text_field.dart';

import '../services/services.dart';
import '../vehicle_market/vehicle_market.dart';

class HomePage extends StatelessWidget {
  final User activeUser;

  const HomePage(this.activeUser);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          body: _buildBody(context, state.currentTab),
          bottomNavigationBar:
          _buildBottomNavigationBar(context, state.currentTab),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, NavigationTab currentTab) {
    switch (currentTab) {
      case NavigationTab.home:
        return HomeScreen(activeUser: activeUser);
      case NavigationTab.chat:
        return MultiBlocProvider(
          providers: [
            BlocProvider<MessageBloc>.value(
              value: BlocProvider.of<MessageBloc>(context),
            ),
            BlocProvider<ChatsUpdaterCubit>.value(
              value: BlocProvider.of<ChatsUpdaterCubit>(context),
            ),
            BlocProvider<TypingNotificationBloc>.value(
              value: BlocProvider.of<TypingNotificationBloc>(context),
            ),
            BlocProvider<MessageThreadCubit>.value(
              value: BlocProvider.of<MessageThreadCubit>(context),
            ),
            BlocProvider<ReceiptBloc>.value(
              value: BlocProvider.of<ReceiptBloc>(context),
            ),
            BlocProvider<GroupChatBloc>.value(
              value: BlocProvider.of<GroupChatBloc>(context),
            ),
          ],
          child: ChatScreen(
            activeUser: activeUser,
            messageBloc: context.read<MessageBloc>(),
            chatsCubit: context.read<ChatsUpdaterCubit>(),
            typingNotificationBloc: context.read<TypingNotificationBloc>(),
            messageThreadCubit: context.read<MessageThreadCubit>(),
            receiptBloc: context.read<ReceiptBloc>(),
            groupChatBloc: context.read<GroupChatBloc>(),
          ),
        );
      case NavigationTab.market:
        return BlocProvider<AuctionBloc>.value(
          value: BlocProvider.of<AuctionBloc>(context),
          child: VehicleMarketScreen(activeUser),
        );
      case NavigationTab.forum:
        return BlocProvider<ForumBloc>.value(
          value: BlocProvider.of<ForumBloc>(context),
          child: ForumScreen(user: activeUser),
        );
      case NavigationTab.services:
        return BlocProvider<HomePageBloc>.value(
          value: BlocProvider.of<HomePageBloc>(context),
          child: ServicesScreen(activeUser: activeUser,),
        );
    }
  }

  Widget _buildBottomNavigationBar(
      BuildContext context, NavigationTab currentTab) {
    return BottomNavigationBar(
      backgroundColor: isLightTheme(context) ? kCreamLM : kBlue,
      selectedItemColor: isLightTheme(context) ? kPurpleBlueDM : kLightBlueGrayDM,
      unselectedItemColor: isLightTheme(context) ? kBlue : kBubbleBlue,
      currentIndex: currentTab.index,
      onTap: (index) {
        context
            .read<NavigationBloc>()
            .add(TabSelected(NavigationTab.values[index]));
      },
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home',),
        BottomNavigationBarItem(
          icon: ColorFiltered(
            colorFilter: ColorFilter.mode(
              kBlue ?? Colors.black,
              BlendMode.srcIn,
            ),
            child: SizedBox(
              width: 24,
              height: 24,
              child: Image.asset('assets/images/CHAT-blue2.png'),
            ),
          ),
          label: 'Chat',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Market'),
        BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Forum'),
        BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Services'),
      ],
    );
  }
}

class HomeScreen extends StatelessWidget {
  final User activeUser;

  const HomeScreen({required this.activeUser});

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomePageBloc, HomePageState>(
      listener: (context, state) {
        if (state is HomeMyCarSuccess) {
          Navigator.pushNamed(
            context,
            'my_car',
            arguments: {
              'user': activeUser,
              'last_test_date': state.lastTest,
              'test_expiration_date': state.testExpiryDate,
              'on_road_date': state.onRoadSince,
            },
          ).then((_) {

          });
        } else if (state is HomeMyCarFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error occurred while fetching car details.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Container(
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: IconButton(
              icon: Icon(Icons.edit, color: kBubblePurple),
              onPressed: () {
                Navigator.pushNamed(context, 'profile_page',
                    arguments: activeUser).then((_) {
                  // Navigate back to the home screen when the "back" button is pressed
                });
              },
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Logo(),
            ),
          ],
          backgroundColor: kBubblePurple,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Column(
                  children: [
                    SizedBox(height: 160),
                    CustomTextField(
                      hint: 'Search a vehicle license plate...',
                      onChanged: (value) {},
                    ),
                    SizedBox(height: 45),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildConfigurableButton(
                          onPressed: () {
                            var auth = context.read<AuthBloc>().getToken();
                            Navigator.pushNamed(context, 'services', arguments: auth).then((_) {});
                          },
                          icon: Icons.local_parking_outlined,
                          label: 'Locate Parking',
                          backgroundColor: kBlue,
                          iconSize: 40,
                          padding: EdgeInsets.all(10),
                          borderRadius: 40,
                          size: Size(120, 120), // Adjust size as needed
                          textStyle: TextStyle(fontSize: 12, color: kCreamLM),
                        ),
                        _buildConfigurableButton(
                          onPressed: () {
                            ParkingBloc pBloc = context.read<ParkingBloc>();
                            Navigator.pushNamed(context, 'parking').then((_) {});
                          },
                          icon: Icons.car_repair,
                          label: 'Button 2',
                          backgroundColor: kBlue,
                          iconSize: 40,
                          padding: EdgeInsets.all(10),
                          borderRadius: 40,
                          size: Size(120, 120), // Adjust size as needed
                          textStyle: TextStyle(fontSize: 12, color: kCreamLM),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              SizedBox(height: 10),
              _buildConfigurableButton(
                onPressed: () {
                  context.read<HomePageBloc>()
                      .add(HomeMyCarPressed(activeUser.vehicle.carId));
                },
                label: 'My Car',
                backgroundColor: kDarkBubblePurple,
                padding: EdgeInsets.all(20),
                borderRadius: 30,
                size: Size(285, 60), // Adjust height as needed
                textStyle: TextStyle(fontSize: 16, color: kCreamLM, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigurableButton({
    required VoidCallback onPressed,
    IconData? icon,
    required String label,
    Color? backgroundColor,
    double? iconSize,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
    TextStyle? textStyle,
    Size? size, // Add this parameter
  }) {
    return SizedBox(
      width: size?.width,
      height: size?.height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: padding,
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 0),
          ),
        ),
        child: icon != null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize, color: kCreamLM,),
            SizedBox(height: 4),
            Text(label, style: textStyle, textAlign: TextAlign.center),
          ],
        )
            : Text(label, style: textStyle, textAlign: TextAlign.center),
      ),
    );
  }
}