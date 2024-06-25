import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vehicle_me/data/repositories/auctions/auction_service_contract.dart';

import '../../../data/datasource/datasource_contract.dart';
import '../../../data/factories/local_database_factory.dart';
import '../../models/auction.dart';

part 'auction_event.dart';
part 'auction_state.dart';

// BLoC
class AuctionBloc extends Bloc<AuctionEvent, AuctionState> {
  final IAuctionService auctionService;

  AuctionBloc(this.auctionService,
  ) : super(AuctionState()) {
    on<LoadAuctions>(_onLoadAuctions);
    on<LoadCarData>(_onLoadCarData);
    on<AddAuction>(_onAddAuction);
    on<UpdateSelectedManufacturer>(_onUpdateSelectedManufacturer);
    on<UpdateSelectedModel>(_onUpdateSelectedModel);
    on<UpdateSelectedYear>(_onUpdateSelectedYear);
  }

  Future<void> _onLoadAuctions(LoadAuctions event, Emitter<AuctionState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final auctions = await auctionService.fetchAuctions();
      emit(state.copyWith(auctions: auctions, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to load auctions: $e', isLoading: false));
    }
  }

  Future<void> _onLoadCarData(LoadCarData event, Emitter<AuctionState> emit) async {
    try {
      final String response = await rootBundle.loadString('assets/vehicles.json');
      final List<dynamic> data = json.decode(response);
      final Map<String, List<String>> carModels =
      {for (var item in data) item['brand']: List<String>.from(item['models'])};

      final String firstManufacturer = carModels.keys.first;
      final String firstModel = carModels[firstManufacturer]?.first ?? '';

      emit(state.copyWith(
        carModels: carModels,
        selectedManufacturer: firstManufacturer,
        selectedModel: firstModel,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to load car data: $e', isLoading: false));
    }
  }

  Future<void> _onAddAuction(AddAuction event, Emitter<AuctionState> emit) async {
    try {
      await auctionService.addAuction(event.auction);
      final updatedAuctions = List<Auction>.from(state.auctions)..add(event.auction);
      emit(state.copyWith(auctions: updatedAuctions));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to add auction: $e'));
    }
  }

  void _onUpdateSelectedManufacturer(UpdateSelectedManufacturer event, Emitter<AuctionState> emit) {
    final String firstModel = state.carModels[event.manufacturer]?.first ?? '';
    emit(state.copyWith(
      selectedManufacturer: event.manufacturer,
      selectedModel: firstModel,
    ));
  }

  void _onUpdateSelectedModel(UpdateSelectedModel event, Emitter<AuctionState> emit) {
    emit(state.copyWith(selectedModel: event.model));
  }

  void _onUpdateSelectedYear(UpdateSelectedYear event, Emitter<AuctionState> emit) {
    emit(state.copyWith(selectedYear: event.year));
  }
}