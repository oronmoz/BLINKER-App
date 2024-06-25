import 'package:flutter_bloc/flutter_bloc.dart';

enum NavigationTab { home, chat, market, forum, services }

class NavigationEvent {}
class TabSelected extends NavigationEvent {
  final NavigationTab tab;
  TabSelected(this.tab);
}

class NavigationState {
  final NavigationTab currentTab;
  NavigationState(this.currentTab);
}

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(NavigationState(NavigationTab.home)) {
    on<TabSelected>((event, emit) {
      emit(NavigationState(event.tab));
    });
  }
}