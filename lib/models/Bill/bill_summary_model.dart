import 'package:equatable/equatable.dart';

class BillSummaryModel extends Equatable {
  final String fnbBillNo;
  final String primaryCustomerName;
  final String phoneNo;
  final String tableNo;
  final int pax;
  final String outlet;
  final String orderType;
  final double subTotal;
  final double bst;
  final double serviceCharge;
  final double discount;
  final double totalAmount;
  final String paymentStatus;
  final double amountSettled;
  final double amountRemaining;
  final String paymentMode;
  final int? journalNo;
  final String? imageFnbBill;
  final DateTime date;
  final DateTime time;

  const BillSummaryModel({
    required this.fnbBillNo,
    required this.primaryCustomerName,
    required this.phoneNo,
    required this.tableNo,
    required this.pax,
    required this.outlet,
    required this.orderType,
    required this.subTotal,
    required this.bst,
    required this.serviceCharge,
    required this.discount,
    required this.totalAmount,
    required this.paymentStatus,
    required this.amountSettled,
    required this.amountRemaining,
    required this.paymentMode,
    this.journalNo,
    this.imageFnbBill,
    required this.date,
    required this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      'fnb_bill_no': fnbBillNo,
      'primary_customer_name': primaryCustomerName,
      'phone_no': phoneNo,
      'table_no': tableNo,
      'pax': pax,
      'outlet': outlet,
      'order_type': orderType,
      'sub_total': subTotal,
      'bst': bst,
      'service_charge': serviceCharge,
      'discount': discount,
      'total_amount': totalAmount,
      'payment_status': paymentStatus,
      'amount_settled': amountSettled,
      'amount_remaing': amountRemaining,
      'payment_mode': paymentMode,
      'journal_no': journalNo,
      'image_fnb_bill': imageFnbBill,
      'date': date.toIso8601String().split('T')[0],
      'time': time.toIso8601String().split('T')[1].substring(0, 8),
    };
  }

  factory BillSummaryModel.fromJson(Map<String, dynamic> json) {
    return BillSummaryModel(
      fnbBillNo: json['fnb_bill_no'],
      primaryCustomerName: json['primary_customer_name'],
      phoneNo: json['phone_no'],
      tableNo: json['table_no'],
      pax: json['pax'],
      outlet: json['outlet'],
      orderType: json['order_type'],
      subTotal: json['sub_total'].toDouble(),
      bst: json['bst'].toDouble(),
      serviceCharge: json['service_charge'].toDouble(),
      discount: json['discount'].toDouble(),
      totalAmount: json['total_amount'].toDouble(),
      paymentStatus: json['payment_status'],
      amountSettled: json['amount_settled'].toDouble(),
      amountRemaining: json['amount_remaing'].toDouble(),
      paymentMode: json['payment_mode'],
      journalNo: json['journal_no'],
      imageFnbBill: json['image_fnb_bill'],
      date: DateTime.parse(json['date']),
      time: DateTime.parse('2000-01-01T${json['time']}'),
    );
  }

  @override
  List<Object?> get props => [
        fnbBillNo,
        primaryCustomerName,
        phoneNo,
        tableNo,
        pax,
        outlet,
        orderType,
        subTotal,
        bst,
        serviceCharge,
        discount,
        totalAmount,
        paymentStatus,
        amountSettled,
        amountRemaining,
        paymentMode,
        journalNo,
        imageFnbBill,
        date,
        time,
      ];
}
