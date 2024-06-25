import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable{}

class ChatCreate extends ChatEvent{
  final List<String> carIds;

  ChatCreate(this.carIds);

  @override
  List<Object?> get props => [carIds];
}

class ChatEventInitial extends ChatEvent{

  @override
  List<Object?> get props => [];

}
