import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:sqflite/sqflite.dart';
import 'package:vehicle_me/data/repositories/auctions/auction_service_contract.dart';
import 'package:vehicle_me/data/repositories/chat/group_service/group_service_impl.dart';
import 'package:vehicle_me/data/repositories/chat/group_service/groups_service_contract.dart';
import 'package:vehicle_me/data/repositories/vehicle_services/locate_service.dart';
import 'package:vehicle_me/data/repositories/vehicle_services/vehicle_service_contract.dart';
import 'package:vehicle_me/data/repositories/vehicle_services/vehicle_service_impl.dart';
import 'package:vehicle_me/domain/state_management/home/chat/groups/group_chat_bloc.dart';
import 'package:vehicle_me/domain/state_management/home/parking/parking_bloc.dart';
import 'package:vehicle_me/domain/state_management/home/vehicle_services/locate_service_bloc.dart';
import 'package:vehicle_me/domain/state_management/vehicle_market/auction_bloc.dart';
import 'package:vehicle_me/data/repositories/forum_service/forum_service_contract.dart';
import 'package:vehicle_me/data/repositories/forum_service/forum_service_impl.dart';
import 'package:vehicle_me/domain/models/forum.dart';
import 'package:vehicle_me/domain/state_management/home/chat/home_cubit.dart';
import 'package:vehicle_me/domain/state_management/home/forum/forum_bloc.dart';
import 'package:vehicle_me/domain/state_management/home/home_bloc.dart';
import 'package:vehicle_me/ui/pages/home/locate_parking.dart';
import 'package:vehicle_me/ui/pages/home/locate_services.dart';
import 'package:vehicle_me/ui/pages/home/my_car.dart';
import 'package:vehicle_me/ui/pages/home/profile_page.dart';
import 'package:vehicle_me/ui/pages/onboarding/login.dart';
import 'package:vehicle_me/domain/state_management/login/login_cubit.dart';
import 'package:vehicle_me/ui/pages/chat/message_thread.dart';
import 'package:vehicle_me/ui/pages/onboarding/second_slide.dart';
import 'package:vehicle_me/ui/pages/onboarding/third_slide.dart';
import 'config.dart';
import 'package:get_it/get_it.dart';
import 'package:vehicle_me/ui/pages/forum/post_detail_page.dart';

// Models Imports
import 'data/repositories/auctions/auction_service_impl.dart';
import 'domain/models/chat.dart';
import 'domain/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

// BLoCs Imports
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vehicle_me/domain/state_management/home/chat/message/message_bloc.dart';
import 'package:vehicle_me/domain/state_management/auth/auth_bloc.dart';
import 'package:vehicle_me/domain/state_management/home/chat/receipt/receipt_bloc.dart';
import 'package:vehicle_me/domain/state_management/home/chat/typing_notification/typing_notification_bloc.dart';
import 'package:vehicle_me/domain/state_management/onboarding/onboarding_bloc.dart';
import 'package:vehicle_me/domain/state_management/home/chat/chat_cubit.dart';
import 'package:vehicle_me/domain/state_management/home/chat/chats_updater_cubit.dart';
import 'package:vehicle_me/domain/state_management/home/message_thread/message_thread_cubit.dart';
import 'package:vehicle_me/state_management/signup/profile_image_cubit.dart';

// ViewModels
import 'package:vehicle_me/domain/state_management/home/chat/viewmodels/chat_viewmodel.dart';
import 'package:vehicle_me/domain/state_management/home/chat/viewmodels/chats_viewmodel.dart';

// Services Imports
import 'package:vehicle_me/data/datasource/datasource_contract.dart';
import 'package:vehicle_me/data/repositories/chat/typing_events/typing_notification_service.dart';
import 'package:vehicle_me/data/repositories/user/user_service_contract.dart';
import 'data/repositories/chat/receipts/receipt_service.dart';
import 'package:vehicle_me/data/data_providers/image_uploader.dart';
import 'package:vehicle_me/data/factories/local_database_factory.dart';
import 'package:vehicle_me/data/repositories/chat/messages/encryption_service.dart';
import 'package:vehicle_me/data/repositories/chat/messages/message_service.dart';

// TODO: Figure why these are needed despite contracts:
import 'package:vehicle_me/data/repositories/chat/messages/message_service_impl.dart';
import 'package:vehicle_me/data/repositories/chat/messages/encryption_service_impl.dart';
import 'data/repositories/chat/typing_events/typing_notification_service_impl.dart';
import 'package:vehicle_me/data/repositories/chat/receipts/receipt_service_impl.dart';
import 'package:vehicle_me/data/repositories/user/user_service.dart';
import 'package:vehicle_me/data/datasource/datasource.dart';

// Pages Imports
import 'package:vehicle_me/ui/pages/home/home.dart';
import 'package:vehicle_me/ui/pages/onboarding/first_slide.dart';

import 'domain/models/vehicle.dart';
import 'domain/state_management/home/navigation_bloc.dart';

/// Dependency Injection
///
/// Sets up and initializes all dependencies used in the application.
///
/// This method ensures that all necessary services and dependencies are registered
/// and ready to be used throughout the application. It catches any initialization
/// errors and propagates them to the caller for appropriate handling.

class CompositionRoot {
  static GetIt locator = GetIt.instance;

  static Future<void> setup() async {
    try {
      locator.registerSingleton(locator);
      await registerDependencies();
    } catch (e, stackTrace) {
      print('Error setting up dependencies: $e');
      print(stackTrace);
    }
  }

  static Future<void> registerDependencies() async {
    locator.registerFactory(() => AuthBloc());

    locator.registerSingleton<String>(baseURL);

    locator.registerLazySingleton(() => LoginBloc(baseURL, getAuthBloc()));

    final key = encrypt.Key.fromUtf8(
        'N3V3rGoNnAg1vEy0uUPneV3rG0nNALeT'); // Ensure key length is 32 bytes
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    locator
        .registerLazySingleton<IEncryption>(() => EncryptionService(encrypter));

    locator.registerLazySingleton<ImageUploader>(
        () => ImageUploader('$baseURL/images/upload/'));

    await _registerAsyncDependencies();
  }

  static Future<void> _registerAsyncDependencies() async {
    locator.registerSingletonAsync<ChatBloc>(() async {
      var token = await getAuthBloc().getToken();
      return ChatBloc(await locator.getAsync<IUserService>(), token);
    });

    locator.registerSingletonAsync<IAuctionService>(() async {
      return AuctionService(getBaseURL());
    });

    locator.registerSingletonAsync<IParkingService>(() async {
      return ParkingService(getBaseURL());
    });

    locator.registerSingletonAsync<LocateServicesAPI>(() async {
      return LocateServicesAPI();
    });

    locator.registerSingletonAsync<ForumBloc>(() async {
      return ForumBloc(await locator.getAsync<IForumService>());
    });

    locator.registerSingletonAsync<LocalDatabaseFactory>(() async {
      return LocalDatabaseFactory();
    });

    locator.registerSingletonAsync<Database>(() async {
      return await LocalDatabaseFactory().createDatabase();
    });

    locator.registerSingletonAsync<IDataSource>(() async {
      final db = await locator.getAsync<Database>();
      return Datasource(db);
    });

    locator.registerSingletonAsync<IUserService>(() async {
      return UserService(baseURL);
    });

    locator.registerSingletonAsync<IMessageService>(() async {
      return MessageService(
        encryption: locator.get<IEncryption>(), await getAuthBloc().getToken()
      );
    });

    locator.registerSingletonAsync<IReceiptService>(() async {
      return ReceiptService(baseURL);
    });

    locator.registerSingletonAsync<ITypingNotification>(() async {
      return TypingNotification(
        await locator.getAsync<IUserService>(),
        baseURL,
      );
    });

    locator.registerSingletonAsync<IGroupService>(() async {
      return GroupService(baseUrl: baseURL);
    });

    locator.registerSingletonAsync<IForumService>(() async {
      return ForumService(getAuthBloc(), getBaseURL());
    });

    locator.registerSingletonAsync<OnboardingBloc>(() async {
      final bloc = OnboardingBloc(await locator.getAsync<IUserService>());
      return bloc;
    });

    locator.registerSingletonAsync<AuctionBloc>(() async {
      final bloc = AuctionBloc(await locator.getAsync<IAuctionService>());
      return bloc;
    });

    locator.registerSingletonAsync<ParkingBloc>(() async {
      final bloc = ParkingBloc(await locator.getAsync<IParkingService>());
      return bloc;
    });

    locator.registerSingletonAsync<LocateServicesBloc>(() async {
      final bloc =
          LocateServicesBloc(await locator.getAsync<LocateServicesAPI>());
      return bloc;
    });

    locator.registerSingletonAsync<ChatsViewModel>(() async {
      return ChatsViewModel(
        await locator.getAsync<IDataSource>(),
        await locator.getAsync<IUserService>(),
        await getAuthBloc().getToken()
      );
    });

    locator.registerSingletonAsync<ChatViewModel>(() async {
      return ChatViewModel(await locator.getAsync<IDataSource>(), 0);
    });

    locator.registerSingletonAsync<ChatsUpdaterCubit>(() async {
      return ChatsUpdaterCubit(await locator.getAsync<ChatsViewModel>());
    });

    locator.registerSingletonAsync<GroupChatBloc>(() async {
      return GroupChatBloc(await getGroupService());
    });

    locator.registerSingletonAsync<MessageThreadCubit>(() async {
      return MessageThreadCubit(await locator.getAsync<ChatViewModel>());
    });

    locator.registerSingletonAsync<ReceiptBloc>(() async {
      return ReceiptBloc(await locator.getAsync<IReceiptService>());
    });

    locator.registerSingletonAsync<TypingNotificationBloc>(() async {
      return TypingNotificationBloc(
        await locator.getAsync<ITypingNotification>(),
      );
    });

    locator.registerSingletonAsync<MessageBloc>(() async {
      return MessageBloc(await locator.getAsync<IMessageService>());
    });

    locator.registerSingletonAsync<HomeCubit>(() async {
      return HomeCubit(await locator.getAsync<IUserService>());
    });

    locator.registerSingletonAsync<NavigationBloc>(() async {
      return NavigationBloc();
    });

    locator.registerSingletonAsync<ProfileImageCubit>(() async {
      return ProfileImageCubit();
    });

    locator.registerSingletonAsync<HomePageBloc>(() async {
      return HomePageBloc(
          await locator.getAsync<IUserService>(), getAuthBloc());
    });

  }

  static AuthBloc getAuthBloc() {
    assert(locator.isRegistered<AuthBloc>(), 'AuthBloc is not registered');
    return locator<AuthBloc>();
  }

  static LoginBloc getLoginBloc() {
    assert(locator.isRegistered<LoginBloc>(), 'LoginBloc is not registered');
    return locator<LoginBloc>();
  }

  static String getBaseURL() {
    assert(locator.isRegistered<String>(), 'Base URL is not initialized');
    return locator<String>();
  }

  static IUserService getUserService() {
    assert(
        locator.isRegistered<IUserService>(), 'UserService is not registered');
    return locator<IUserService>();
  }

  static IMessageService getMessageService() {
    assert(locator.isRegistered<IMessageService>(),
        'MessageService is not registered');
    return locator<IMessageService>();
  }

  static IReceiptService getReceiptService() {
    assert(locator.isRegistered<IReceiptService>(),
        'ReceiptService is not registered');
    return locator<IReceiptService>();
  }

  static ITypingNotification getNotificationService() {
    assert(locator.isRegistered<ITypingNotification>(),
        'TypingNotification is not registered');
    return locator<ITypingNotification>();
  }

  static IAuctionService getAuctionService() {
    assert(locator.isRegistered<IAuctionService>(),
        'IAuctionService is not registered');
    return locator<IAuctionService>();
  }

  static IForumService getIForumService() {
    assert(locator.isRegistered<IForumService>(),
        'IForumService is not registered');
    return locator<IForumService>();
  }

  static IParkingService getParkingService() {
    assert(locator.isRegistered<IForumService>(),
        'IParkingService is not registered');
    return locator<IParkingService>();
  }

  static Future<IGroupService> getGroupService() async {
    assert(locator.isRegistered<IGroupService>(),
    'IGroupService is not registered');
    return await locator.getAsync<IGroupService>();
  }

  static LocateServicesAPI getLocateServicesAPI() {
    assert(locator.isRegistered<LocateServicesAPI>(),
        'IParkingService is not registered');
    return locator<LocateServicesAPI>();
  }

  static Database getDatabase() {
    assert(locator.isRegistered<Database>(), 'Database is not registered');
    return locator<Database>();
  }

  static IDataSource getDataSource() {
    assert(locator.isRegistered<IDataSource>(), 'DataSource is not registered');
    return locator<IDataSource>();
  }

  static ChatViewModel getChatViewmodel() {
    assert(locator.isRegistered<ChatViewModel>(),
        'ChatViewmodel is not registered');
    return locator<ChatViewModel>();
  }

  static ChatsViewModel getChatsViewModel() {
    assert(locator.isRegistered<ChatsViewModel>(),
        'ChatsViewModel is not registered');
    return locator<ChatsViewModel>();
  }

  static ChatsUpdaterCubit getChatUpdaterCubit() {
    assert(locator.isRegistered<ChatsUpdaterCubit>(),
        'ChatsUpdaterCubit is not registered');
    return locator<ChatsUpdaterCubit>();
  }

  static OnboardingBloc getOnboardingBloc() {
    assert(locator.isRegistered<OnboardingBloc>(),
        'OnboardingBloc is not registered');
    return locator<OnboardingBloc>();
  }

  static ParkingBloc getParkingBloc() {
    assert(locator.isRegistered<ParkingBloc>(),
        'OnboardingBloc is not registered');
    return locator<ParkingBloc>();
  }

  static LocateServicesBloc getLocateServicesBloc() {
    assert(locator.isRegistered<LocateServicesBloc>(),
        'OnboardingBloc is not registered');
    return locator<LocateServicesBloc>();
  }

  static MessageBloc getMessageBloc() {
    assert(
        locator.isRegistered<MessageBloc>(), 'MessageBloc is not registered');
    return locator<MessageBloc>();
  }

  static ReceiptBloc getReceiptBloc() {
    assert(
        locator.isRegistered<ReceiptBloc>(), 'ReceiptBloc is not registered');
    return locator<ReceiptBloc>();
  }

  static TypingNotificationBloc getTypingNotificationBloc() {
    assert(locator.isRegistered<TypingNotificationBloc>(),
        'TypingNotificationBloc is not registered');
    return locator<TypingNotificationBloc>();
  }

  static GroupChatBloc getGroupChatBloc() {
    assert(
    locator.isRegistered<GroupChatBloc>(), 'GroupChatBloc is not registered');
    return locator<GroupChatBloc>();
  }

  static HomeCubit getHomeCubit() {
    assert(locator.isRegistered<HomeCubit>(), 'ChatCubit is not registered');
    return locator<HomeCubit>();
  }

  static ChatBloc getChatCubit() {
    assert(locator.isRegistered<ChatBloc>(), 'ChatCubit is not registered');
    return locator<ChatBloc>();
  }

  static MessageThreadCubit getMessageThreadCubit() {
    assert(locator.isRegistered<MessageThreadCubit>(),
        'MessageThreadCubit is not registered');
    return locator<MessageThreadCubit>();
  }

  static ImageUploader getImageUploader() {
    assert(locator.isRegistered<ImageUploader>(),
        'ImageUploader is not registered');
    return locator<ImageUploader>();
  }

  static LocalDatabaseFactory getLocalDatabaseFactory() {
    assert(locator.isRegistered<LocalDatabaseFactory>(),
        'LocalDatabaseFactory is not registered');
    return locator<LocalDatabaseFactory>();
  }

  static ProfileImageCubit getProfileImageCubit() {
    assert(locator.isRegistered<ProfileImageCubit>(),
        'ProfileImageCubit is not registered');
    return locator<ProfileImageCubit>();
  }

  static AuctionBloc getAuctionBloc() {
    assert(
        locator.isRegistered<AuctionBloc>(), 'AuctionBloc is not registered');
    return locator<AuctionBloc>();
  }

  static ForumBloc getForumBloc() {
    assert(locator.isRegistered<ForumBloc>(), 'ForumBloc is not registered');
    return locator<ForumBloc>();
  }

  static HomePageBloc getHomeBloc() {
    assert(locator.isRegistered<HomeCubit>(), 'HomeBloc is not registered');
    return locator<HomePageBloc>();
  }

  static NavigationBloc getNavigationBloc() {
    assert(locator.isRegistered<NavigationBloc>(),
        'NavigationBloc is not registered');
    return locator<NavigationBloc>();
  }

  /// Composes the first slide of the onboarding process using OnboardingBloc.
  ///
  /// This method wraps OnboardingBloc in a MultiBlocProvider to provide state management.
  static Widget composeOnboardingFirstSlide() {
    final OnboardingBloc onboardingBloc = getOnboardingBloc();

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: onboardingBloc),
      ],
      child: OnboardingFirstSlide(),
    );
  }

  static Widget composeOnboardingSecondSlide(String carID) {
    OnboardingBloc onboardingBloc = getOnboardingBloc();

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: onboardingBloc),
      ],
      child: OnboardingSecondSlide(
        carID: carID,
      ),
    );
  }

  static Widget composeOnboardingThirdSlide(User user) {
    saveUser(user);

    OnboardingBloc onboardingBloc = getOnboardingBloc();
    LoginBloc loginBloc = getLoginBloc();
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: onboardingBloc),
        BlocProvider.value(value: loginBloc),
      ],
      child: OnboardingThirdSlide(),
    );
  }

  /// Composes the first slide of the onboarding process using OnboardingBloc.
  ///
  /// This method wraps OnboardingBloc in a MultiBlocProvider to provide state management.
  static Widget composeLoginScreenUI() {
    LoginBloc _loginBloc = getLoginBloc();
    AuthBloc _authBloc = getAuthBloc();
    OnboardingBloc _onboardingBloc = getOnboardingBloc();
    ProfileImageCubit _profileImageCubit = getProfileImageCubit();

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _loginBloc),
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _profileImageCubit),
        BlocProvider.value(value: _onboardingBloc),
      ],
      child: LoginScreen(),
    );
  }

  /// Composes the home UI widget.
  ///
  /// This method ensures that all required dependencies are initialized
  /// before creating and providing BLoCs and Cubits to the HomePage.
  static Widget composeHomeUI(User user) {
    return FutureBuilder(
      future: Future.wait([
        locator.allReady(),
        // Add any other specific async dependencies you need to wait for
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          NavigationBloc _navigationBloc = getNavigationBloc();
          AuthBloc _authBloc = getAuthBloc();
          ChatBloc _chatCubit = getChatCubit();
          MessageBloc _messageBloc = getMessageBloc();
          ChatsUpdaterCubit _chatUpdater = getChatUpdaterCubit();
          HomeCubit _homeCubit = getHomeCubit();
          HomePageBloc _homeBloc = getHomeBloc();
          AuctionBloc _auctionBloc = getAuctionBloc();
          ForumBloc _forumBloc = getForumBloc();
          ParkingBloc _parkingBloc = getParkingBloc();
          LocateServicesBloc _locateServicesBloc = getLocateServicesBloc();
          GroupChatBloc _groupChatBloc = getGroupChatBloc();
          TypingNotificationBloc _typingNotificationBloc = getTypingNotificationBloc();
          MessageThreadCubit _messageThreadCubit = getMessageThreadCubit();
          ReceiptBloc _receiptBloc = getReceiptBloc();

          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: _chatCubit),
              BlocProvider.value(value: _messageBloc),
              BlocProvider.value(value: _chatUpdater),
              BlocProvider.value(value: _homeCubit),
              BlocProvider.value(value: _authBloc),
              BlocProvider.value(value: _homeBloc),
              BlocProvider.value(value: _navigationBloc),
              BlocProvider.value(value: _forumBloc),
              BlocProvider.value(value: _auctionBloc),
              BlocProvider.value(value: _parkingBloc),
              BlocProvider.value(value: _locateServicesBloc),
              BlocProvider.value(value: _groupChatBloc),
              BlocProvider.value(value: _typingNotificationBloc),
              BlocProvider.value(value: _messageThreadCubit),
              BlocProvider.value(value: _receiptBloc),
            ],
            child: HomePage(user),
          );
        } else {
          // Show a loading indicator while waiting for dependencies to initialize
          return CircularProgressIndicator();
        }
      },
    );
  }

  /// Composes the home UI widget.
  ///
  /// This method ensures that all required dependencies are initialized
  /// before creating and providing BLoCs and Cubits to the HomePage.
  static Widget composeProfilePageUI(User user) {
    assert(locator.isRegistered<AuthBloc>(), 'Auth is not initialized');

    AuthBloc _authBloc = getAuthBloc();

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
      ],
      child: ProfilePage(user: user),
    );
  }

  static Widget composeLocateParking() {
    assert(
        locator.isRegistered<ParkingBloc>(), 'ParkingBloc is not initialized');

    ParkingBloc _parkingBloc = getParkingBloc();

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _parkingBloc),
      ],
      child: ParkingPage(),
    );
  }

  static Widget composeLocateServices(String token) {
    assert(
        locator.isRegistered<ParkingBloc>(), 'ParkingBloc is not initialized');

    LocateServicesBloc _locateServicesBloc = getLocateServicesBloc();

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _locateServicesBloc),
      ],
      child: LocateServicesPage(),
    );
  }

  static Widget composePostDetailPageUI(User activeUser, ForumPost post) {
    assert(locator.isRegistered<ForumBloc>(), 'ForumBloc is not initialized');

    ForumBloc _forumBloc = getForumBloc();

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _forumBloc),
      ],
      child: PostDetailPage(user: activeUser, post: post),
    );
  }

  static Widget composeMyCarUI(User activeUser, String last_test_date,
      String test_expiration_date, String on_road_date) {
    assert(locator.isRegistered<ForumBloc>(), 'ForumBloc is not initialized');

    HomePageBloc _homeBloc = getHomeBloc();

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _homeBloc),
      ],
      child: MyCarPage(
          user: activeUser,
          last_test_date: last_test_date,
          test_expiration_date: test_expiration_date,
          on_road_date: on_road_date),
    );
  }

  /// Composes the message thread UI widget.
  ///
  /// This method ensures that MessageThreadCubit and ReceiptBloc are initialized
  /// before creating and providing BLoCs and Cubits to the MessageThread widget.
  static Widget composeMessageThreadUI(
     List<User> members, User me, Chat chat) {

    assert(locator.isRegistered<MessageThreadCubit>(),
        'MessageThreadCubit is not initialized');
    assert(locator.isRegistered<ChatsUpdaterCubit>(),
        'ChatsUpdaterCubit is not initialized');
    assert(locator.isRegistered<TypingNotificationBloc>(),
        'TypingNotificationBloc is not initialized');

    MessageBloc _messageBloc = getMessageBloc();
    ChatsUpdaterCubit _chatUpdaterCubit = getChatUpdaterCubit();
    TypingNotificationBloc _typingNotificationBloc =
        getTypingNotificationBloc();
    ReceiptBloc _receiptBloc = getReceiptBloc();
    MessageThreadCubit _messageThreadCubit = getMessageThreadCubit();


    return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _messageThreadCubit),
          BlocProvider.value(value: _receiptBloc),
          BlocProvider.value(value: _messageBloc),
          BlocProvider.value(value: _chatUpdaterCubit),
          BlocProvider.value(value: _typingNotificationBloc),

        ],
        child: MessageThread(members, me, _messageBloc, _chatUpdaterCubit,
            _typingNotificationBloc, chat));
  }
}

Future<User?> getUser() async {
  final prefs = await SharedPreferences.getInstance();
  String? userJson = prefs.getString('user');
  if (userJson == null) {
    return null; // Return null if no user is found
  }
  Map<String, dynamic> userMap = jsonDecode(userJson);
  return User.fromJson(userMap);
}

Future<void> saveUser(User user) async {
  final prefs = await SharedPreferences.getInstance();
  String userJson = jsonEncode(user.toJson());
  await prefs.setString('user', userJson);
}
