import '../../../domain/models/auction.dart';

abstract class IAuctionService{

  Future<List<Auction>> fetchAuctions();

  Future<void> addAuction(Auction auction);

}