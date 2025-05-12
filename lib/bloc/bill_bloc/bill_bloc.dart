import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/models/Bill/bill_summary_model.dart';
import 'package:pos_system_legphel/models/Bill/bill_details_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

part 'bill_event.dart';
part 'bill_state.dart';

class BillBloc extends Bloc<BillEvent, BillState> {
  final String baseUrl = 'http://119.2.105.142:3800'; // Your API base URL

  BillBloc() : super(BillInitial()) {
    on<SubmitBill>(_onSubmitBill);
    on<LoadBill>(_onLoadBill);
    on<UpdateBill>(_onUpdateBill);
    on<DeleteBill>(_onDeleteBill);
  }

  Future<void> _onSubmitBill(SubmitBill event, Emitter<BillState> emit) async {
    try {
      emit(BillLoading());

      // Submit bill summary
      final summaryResponse = await http.post(
        Uri.parse('$baseUrl/api/fnb_bill_summary_legphel_eats'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(event.billSummary.toJson()),
      );

      if (summaryResponse.statusCode != 200 &&
          summaryResponse.statusCode != 201) {
        throw Exception(
            'Failed to submit bill summary: ${summaryResponse.body}');
      }

      // Submit bill details
      for (var detail in event.billDetails) {
        final detailResponse = await http.post(
          Uri.parse('$baseUrl/api/fnb_bill_details_legphel_eats'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(detail.toJson()),
        );

        if (detailResponse.statusCode != 200 &&
            detailResponse.statusCode != 201) {
          throw Exception(
              'Failed to submit bill detail: ${detailResponse.body}');
        }
      }

      emit(BillSubmitted(event.billSummary.fnbBillNo));
    } catch (e) {
      emit(BillError(e.toString()));
    }
  }

  Future<void> _onLoadBill(LoadBill event, Emitter<BillState> emit) async {
    try {
      emit(BillLoading());

      // Load bill summary
      final summaryResponse = await http.get(
        Uri.parse(
            '$baseUrl/api/fnb_bill_summary_legphel_eats/${event.fnbBillNo}'),
      );

      if (summaryResponse.statusCode != 200) {
        throw Exception('Failed to load bill summary: ${summaryResponse.body}');
      }

      final summary =
          BillSummaryModel.fromJson(jsonDecode(summaryResponse.body));

      // Load bill details
      final detailsResponse = await http.get(
        Uri.parse(
            '$baseUrl/api/fnb_bill_details_legphel_eats?fnb_bill_no=${event.fnbBillNo}'),
      );

      if (detailsResponse.statusCode != 200) {
        throw Exception('Failed to load bill details: ${detailsResponse.body}');
      }

      final List<dynamic> detailsJson = jsonDecode(detailsResponse.body);
      final details =
          detailsJson.map((json) => BillDetailsModel.fromJson(json)).toList();

      emit(BillLoaded(billSummary: summary, billDetails: details));
    } catch (e) {
      emit(BillError(e.toString()));
    }
  }

  Future<void> _onUpdateBill(UpdateBill event, Emitter<BillState> emit) async {
    try {
      emit(BillLoading());

      // Update bill summary
      final summaryResponse = await http.put(
        Uri.parse(
            '$baseUrl/api/fnb_bill_summary_legphel_eats/${event.billSummary.fnbBillNo}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(event.billSummary.toJson()),
      );

      if (summaryResponse.statusCode != 200) {
        throw Exception(
            'Failed to update bill summary: ${summaryResponse.body}');
      }

      // Delete existing bill details
      await http.delete(
        Uri.parse(
            '$baseUrl/api/fnb_bill_details_legphel_eats/${event.billSummary.fnbBillNo}'),
      );

      // Submit new bill details
      for (var detail in event.billDetails) {
        final detailResponse = await http.post(
          Uri.parse('$baseUrl/api/fnb_bill_details_legphel_eats'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(detail.toJson()),
        );

        if (detailResponse.statusCode != 200 &&
            detailResponse.statusCode != 201) {
          throw Exception(
              'Failed to update bill detail: ${detailResponse.body}');
        }
      }

      emit(BillSubmitted(event.billSummary.fnbBillNo));
    } catch (e) {
      emit(BillError(e.toString()));
    }
  }

  Future<void> _onDeleteBill(DeleteBill event, Emitter<BillState> emit) async {
    try {
      emit(BillLoading());

      // Delete bill details first
      await http.delete(
        Uri.parse(
            '$baseUrl/api/fnb_bill_details_legphel_eats/${event.fnbBillNo}'),
      );

      // Delete bill summary
      final response = await http.delete(
        Uri.parse(
            '$baseUrl/api/fnb_bill_summary_legphel_eats/${event.fnbBillNo}'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete bill: ${response.body}');
      }

      emit(BillInitial());
    } catch (e) {
      emit(BillError(e.toString()));
    }
  }
}
