import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:vehicle_me/domain/models/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../data/repositories/chat/receipts/receipt_service.dart';
import 'package:vehicle_me/domain/models/receipt.dart';

part 'receipt_event.dart';
part 'receipt_state.dart';

class ReceiptBloc extends Bloc<ReceiptEvent, ReceiptState> {
  final IReceiptService _receiptService;

  ReceiptBloc(this._receiptService) : super(ReceiptState.initial()) {
    on<Subscribed>(_onSubscribed);
    on<ReceiptSent>(_onReceiptSent);
    on<_ReceiptReceived>(_onReceiptReceived);
  }

  void _onSubscribed(Subscribed event, Emitter<ReceiptState> emit) {
    _receiptService.receipts(event.user).listen((receipt) {
      add(_ReceiptReceived(receipt));
    });
  }

  Future<void> _onReceiptSent(ReceiptSent event, Emitter<ReceiptState> emit) async {
    await _receiptService.send(event.receipt);
    emit(ReceiptState.sent(event.receipt));
  }

  void _onReceiptReceived(_ReceiptReceived event, Emitter<ReceiptState> emit) {
    emit(ReceiptState.received(event.receipt));
  }

  @override
  Future<void> close() {
    _receiptService.dispose();
    return super.close();
  }
}