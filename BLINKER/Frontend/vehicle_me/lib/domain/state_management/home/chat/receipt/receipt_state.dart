part of 'receipt_bloc.dart';

abstract class ReceiptState extends Equatable {
  const ReceiptState();

  factory ReceiptState.initial() => ReceiptInitial();

  factory ReceiptState.sent(Receipt receipt) => ReceiptSentSuccess(receipt);

  factory ReceiptState.received(Receipt receipt) =>
      ReceiptReceiveSuccess(receipt);

  @override
  List<Object> get props => [];
}

class ReceiptInitial extends ReceiptState {}

class ReceiptSentSuccess extends ReceiptState {
  final Receipt receipt;

  const ReceiptSentSuccess(this.receipt);

  @override
  List<Object> get props => [receipt];
}

class ReceiptReceiveSuccess extends ReceiptState {
  final Receipt receipt;

  const ReceiptReceiveSuccess(this.receipt);

  @override
  List<Object> get props => [receipt];
}
