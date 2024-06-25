import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vehicle_me/data/repositories/auctions/auction_service_contract.dart';

import '../../../domain/models/auction.dart';

/// Provides functionality for fetching and adding auctions.
class AuctionService extends IAuctionService {

  final String BaseURL;

  /// Constructs a new [AuctionService] instance.
  ///
  /// [BaseURL] - The base URL of the API.
  AuctionService(this.BaseURL);

  /// Fetches the list of auctions from the API.
  ///
  /// Returns a list of [Auction] instances.
  ///
  /// Throws an [Exception] if the fetch operation fails.
  Future<List<Auction>> fetchAuctions() async {
    final response = await http.get(Uri.parse('$BaseURL/auctions/get_auctions'));
    if (response.statusCode == 200) {
      final List<dynamic> auctionData = json.decode(response.body);
      return auctionData.map((auction) => Auction.fromJson(auction)).toList();
    } else {
      throw Exception('Failed to load auctions: ${response.statusCode}');
    }
  }

  /// Adds a new auction to the API.
  ///
  /// [auction] - The [Auction] instance to be added.
  ///
  /// Throws an [Exception] if the add operation fails.
  Future<void> addAuction(Auction auction) async {
    final response = await http.post(
      Uri.parse('$BaseURL/auctions/addNewAuction'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(auction.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add auction: ${response.body}');
    }
  }
}