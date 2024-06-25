import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter, rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/auction.dart';
import '../../../domain/models/user.dart';
import '../../../domain/state_management/vehicle_market/auction_bloc.dart';


class VehicleMarketScreen extends StatefulWidget {
  final User user;

  VehicleMarketScreen(this.user);

  @override
  _VehicleMarketScreenState createState() => _VehicleMarketScreenState();
}

class _VehicleMarketScreenState extends State<VehicleMarketScreen> {
  String selectedPrefix = '050';

  @override
  void initState() {
    super.initState();
    context.read<AuctionBloc>().add(LoadCarData());
    context.read<AuctionBloc>().add(LoadAuctions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<AuctionBloc, AuctionState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state.auctions.isNotEmpty) {
            return _buildAuctionList(state.auctions);
          }
          return Center(child: Text('No auctions available'));
        },
      ),
    );
  }

  Widget _buildAuctionList(List<Auction> auctions) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _showAddAuctionDialog,
              child: Text('Add new post'),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: auctions.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('${auctions[index].manufacturer} ${auctions[index].model}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Year: ${auctions[index].year}'),
                    Text('Price: ₪${auctions[index].price}'),
                    Text('Kilometers: ${auctions[index].kilometers}'),
                    Text('Contact: ${auctions[index].contactName}'),
                    Text('End Time: ${DateFormat('yyyy-MM-dd HH:mm').format(auctions[index].endTime)}'),
                  ],
                ),
                onTap: () => _showAuctionDescriptionDialog(auctions[index]),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showAddAuctionDialog() async {
    TextEditingController carKMController = TextEditingController();
    TextEditingController carPriceController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController contactNameController = TextEditingController();
    TextEditingController contactNumberSuffixController = TextEditingController();

    final auctionBloc = context.read<AuctionBloc>();
    final state = auctionBloc.state;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRowWithTitle('Manufacturer:', DropdownButton<String>(
                value: state.selectedManufacturer,
                onChanged: (value) {
                  auctionBloc.add(UpdateSelectedManufacturer(value!));
                },
                items: state.carModels.keys.map((manufacturer) {
                  return DropdownMenuItem<String>(
                    value: manufacturer,
                    child: Text(manufacturer),
                  );
                }).toList(),
              )),
              _buildRowWithTitle('Year:', DropdownButton<int>(
                value: state.selectedYear,
                onChanged: (value) {
                  auctionBloc.add(UpdateSelectedYear(value!));
                  Navigator.of(context).pop(); // Add this line
                },
                items: List.generate(2025 - 1970, (index) {
                  return DropdownMenuItem<int>(
                    value: 1970 + index,
                    child: Text((1970 + index).toString()),
                  );
                }),
              )),
              _buildRowWithTitle('Model:', DropdownButton<String>(
                value: state.selectedModel,
                onChanged: (value) {
                  auctionBloc.add(UpdateSelectedModel(value!));
                  Navigator.of(context).pop(); // Add this line
                },
                items: state.carModels[state.selectedManufacturer]?.map((model) {
                  return DropdownMenuItem<String>(
                    value: model,
                    child: Text(model),
                  );
                }).toList() ?? [],
              )),
              _buildRowWithTitle('Kilometers:', TextField(
                controller: carKMController,
                decoration: InputDecoration(hintText: 'Enter kilometers'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              )),
              _buildRowWithTitle('Price:', TextField(
                controller: carPriceController,
                decoration: InputDecoration(hintText: 'Enter price'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              )),
              _buildRowWithTitle('Description:', TextField(
                controller: descriptionController,
                decoration: InputDecoration(hintText: 'Enter description'),
                maxLength: 100,
              )),
              _buildRowWithTitle('Contact Name:', TextField(
                controller: contactNameController,
                decoration: InputDecoration(hintText: 'Enter contact name'),
              )),
              _buildRowWithTitle('Contact Number:', Row(
                children: [
                  DropdownButton<String>(
                    value: selectedPrefix,
                    onChanged: (value) {
                      setState(() {
                        selectedPrefix = value!;
                      });
                    },
                    items: ['050', '052', '053', '054'].map((prefix) {
                      return DropdownMenuItem<String>(
                        value: prefix,
                        child: Text(prefix),
                      );
                    }).toList(),
                  ),
                  Expanded(
                    child: TextField(
                      controller: contactNumberSuffixController,
                      decoration: InputDecoration(hintText: 'Enter number'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 7,
                    ),
                  ),
                ],
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_validateInputs(carKMController.text, carPriceController.text, descriptionController.text,
                  contactNameController.text, contactNumberSuffixController.text)) {
                _addNewAuction(
                  state,
                  carKMController.text,
                  carPriceController.text,
                  descriptionController.text,
                  contactNameController.text,
                  contactNumberSuffixController.text,
                );
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  bool _validateInputs(String km, String price, String description, String contactName, String contactNumberSuffix) {
    if (km.isEmpty || price.isEmpty || description.isEmpty || contactName.isEmpty || contactNumberSuffix.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill in all fields')));
      return false;
    }
    return true;
  }

  void _addNewAuction(AuctionState state, String km, String price, String description, String contactName, String contactNumberSuffix) {
    final newAuction = Auction(
      manufacturer: state.selectedManufacturer,
      model: state.selectedModel,
      year: state.selectedYear,
      kilometers: int.parse(km),
      price: int.parse(price),
      description: description,
      contactName: contactName,
      contactNumber: '$selectedPrefix$contactNumberSuffix',
      endTime: DateTime.now().add(Duration(days: 7)),
    );

    context.read<AuctionBloc>().add(AddAuction(newAuction));
    Navigator.of(context).pop();
  }

  Widget _buildRowWithTitle(String title, Widget widget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(title)),
          Expanded(flex: 3, child: widget),
        ],
      ),
    );
  }

  Future<void> _showAuctionDescriptionDialog(Auction auction) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Auction Description'),
        content: Text(auction.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}