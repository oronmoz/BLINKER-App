part of 'auction_bloc.dart';

// Events
abstract class AuctionEvent extends Equatable {
  const AuctionEvent();

  @override
  List<Object> get props => [];
}

class LoadAuctions extends AuctionEvent {}

class LoadCarData extends AuctionEvent {}

class AddAuction extends AuctionEvent {
  final Auction auction;

  const AddAuction(this.auction);

  @override
  List<Object> get props => [auction];
}

class UpdateSelectedManufacturer extends AuctionEvent {
  final String manufacturer;

  const UpdateSelectedManufacturer(this.manufacturer);

  @override
  List<Object> get props => [manufacturer];
}

class UpdateSelectedModel extends AuctionEvent {
  final String model;

  const UpdateSelectedModel(this.model);

  @override
  List<Object> get props => [model];
}

class UpdateSelectedYear extends AuctionEvent {
  final int year;

  const UpdateSelectedYear(this.year);

  @override
  List<Object> get props => [year];
}
