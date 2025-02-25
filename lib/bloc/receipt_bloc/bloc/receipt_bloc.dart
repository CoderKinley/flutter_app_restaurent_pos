import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/data/receipt_data.dart';
import 'package:pos_system_legphel/models/card%20item/receipt_model.dart';

abstract class ReceiptsEvent {}

class LoadReceipts extends ReceiptsEvent {}

class SearchReceipts extends ReceiptsEvent {
  final String query;
  SearchReceipts(this.query);
}

class ReceiptsState {
  final List<Receipt> receipts;
  ReceiptsState(this.receipts);
}

class ReceiptsBloc extends Bloc<ReceiptsEvent, ReceiptsState> {
  final ReceiptRepository repository;

  ReceiptsBloc(this.repository) : super(ReceiptsState([])) {
    on<LoadReceipts>((event, emit) {
      emit(ReceiptsState(repository.fetchReceipts()));
    });

    on<SearchReceipts>((event, emit) {
      List<Receipt> allReceipts = repository.fetchReceipts();
      List<Receipt> filteredReceipts = allReceipts
          .where((receipt) =>
              receipt.id.contains(event.query) ||
              receipt.totalAmount.toString().contains(event.query))
          .toList();
      emit(ReceiptsState(filteredReceipts));
    });
  }
}

abstract class ReceiptDetailsEvent {}

class SelectReceipt extends ReceiptDetailsEvent {
  final Receipt receipt;
  SelectReceipt(this.receipt);
}

class ReceiptDetailsState {
  final Receipt? selectedReceipt;
  ReceiptDetailsState(this.selectedReceipt);
}

class ReceiptDetailsBloc
    extends Bloc<ReceiptDetailsEvent, ReceiptDetailsState> {
  ReceiptDetailsBloc() : super(ReceiptDetailsState(null)) {
    on<SelectReceipt>((event, emit) {
      emit(ReceiptDetailsState(event.receipt));
    });
  }
}
