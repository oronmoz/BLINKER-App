part of 'auction_bloc.dart';

class AuctionState extends Equatable {
  final List<Auction> auctions;
  final Map<String, List<String>> carModels;
  final String selectedManufacturer;
  final String selectedModel;
  final int selectedYear;
  final bool isLoading;
  final String? error;

  const AuctionState({
    this.auctions = const [],
    this.carModels = const {},
    this.selectedManufacturer = '',
    this.selectedModel = '',
    this.selectedYear = 1970,
    this.isLoading = true,
    this.error,
  });

  AuctionState copyWith({
    List<Auction>? auctions,
    Map<String, List<String>>? carModels,
    String? selectedManufacturer,
    String? selectedModel,
    int? selectedYear,
    bool? isLoading,
    String? error,
  }) {
    return AuctionState(
      auctions: auctions ?? this.auctions,
      carModels: carModels ?? this.carModels,
      selectedManufacturer: selectedManufacturer ?? this.selectedManufacturer,
      selectedModel: selectedModel ?? this.selectedModel,
      selectedYear: selectedYear ?? this.selectedYear,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [auctions, carModels, selectedManufacturer, selectedModel, selectedYear, isLoading, error];
}
