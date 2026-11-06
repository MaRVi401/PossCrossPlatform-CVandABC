// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_report_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SalesReportStore on _SalesReportStoreBase, Store {
  Computed<String>? _$formattedStartDateComputed;

  @override
  String get formattedStartDate => (_$formattedStartDateComputed ??=
          Computed<String>(() => super.formattedStartDate,
              name: '_SalesReportStoreBase.formattedStartDate'))
      .value;
  Computed<String>? _$formattedEndDateComputed;

  @override
  String get formattedEndDate => (_$formattedEndDateComputed ??=
          Computed<String>(() => super.formattedEndDate,
              name: '_SalesReportStoreBase.formattedEndDate'))
      .value;

  late final _$startDateAtom =
      Atom(name: '_SalesReportStoreBase.startDate', context: context);

  @override
  DateTime get startDate {
    _$startDateAtom.reportRead();
    return super.startDate;
  }

  @override
  set startDate(DateTime value) {
    _$startDateAtom.reportWrite(value, super.startDate, () {
      super.startDate = value;
    });
  }

  late final _$endDateAtom =
      Atom(name: '_SalesReportStoreBase.endDate', context: context);

  @override
  DateTime get endDate {
    _$endDateAtom.reportRead();
    return super.endDate;
  }

  @override
  set endDate(DateTime value) {
    _$endDateAtom.reportWrite(value, super.endDate, () {
      super.endDate = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_SalesReportStoreBase.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$isExportingPdfAtom =
      Atom(name: '_SalesReportStoreBase.isExportingPdf', context: context);

  @override
  bool get isExportingPdf {
    _$isExportingPdfAtom.reportRead();
    return super.isExportingPdf;
  }

  @override
  set isExportingPdf(bool value) {
    _$isExportingPdfAtom.reportWrite(value, super.isExportingPdf, () {
      super.isExportingPdf = value;
    });
  }

  late final _$isExportingExcelAtom =
      Atom(name: '_SalesReportStoreBase.isExportingExcel', context: context);

  @override
  bool get isExportingExcel {
    _$isExportingExcelAtom.reportRead();
    return super.isExportingExcel;
  }

  @override
  set isExportingExcel(bool value) {
    _$isExportingExcelAtom.reportWrite(value, super.isExportingExcel, () {
      super.isExportingExcel = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_SalesReportStoreBase.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$summaryAtom =
      Atom(name: '_SalesReportStoreBase.summary', context: context);

  @override
  Map<String, dynamic> get summary {
    _$summaryAtom.reportRead();
    return super.summary;
  }

  @override
  set summary(Map<String, dynamic> value) {
    _$summaryAtom.reportWrite(value, super.summary, () {
      super.summary = value;
    });
  }

  late final _$transactionsAtom =
      Atom(name: '_SalesReportStoreBase.transactions', context: context);

  @override
  ObservableList<dynamic> get transactions {
    _$transactionsAtom.reportRead();
    return super.transactions;
  }

  @override
  set transactions(ObservableList<dynamic> value) {
    _$transactionsAtom.reportWrite(value, super.transactions, () {
      super.transactions = value;
    });
  }

  late final _$fetchSalesReportAsyncAction =
      AsyncAction('_SalesReportStoreBase.fetchSalesReport', context: context);

  @override
  Future<void> fetchSalesReport() {
    return _$fetchSalesReportAsyncAction.run(() => super.fetchSalesReport());
  }

  late final _$exportPdfAsyncAction =
      AsyncAction('_SalesReportStoreBase.exportPdf', context: context);

  @override
  Future<bool> exportPdf() {
    return _$exportPdfAsyncAction.run(() => super.exportPdf());
  }

  late final _$exportExcelAsyncAction =
      AsyncAction('_SalesReportStoreBase.exportExcel', context: context);

  @override
  Future<bool> exportExcel() {
    return _$exportExcelAsyncAction.run(() => super.exportExcel());
  }

  late final _$_SalesReportStoreBaseActionController =
      ActionController(name: '_SalesReportStoreBase', context: context);

  @override
  void setDateRange(DateTime start, DateTime end) {
    final _$actionInfo = _$_SalesReportStoreBaseActionController.startAction(
        name: '_SalesReportStoreBase.setDateRange');
    try {
      return super.setDateRange(start, end);
    } finally {
      _$_SalesReportStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
startDate: ${startDate},
endDate: ${endDate},
isLoading: ${isLoading},
isExportingPdf: ${isExportingPdf},
isExportingExcel: ${isExportingExcel},
errorMessage: ${errorMessage},
summary: ${summary},
transactions: ${transactions},
formattedStartDate: ${formattedStartDate},
formattedEndDate: ${formattedEndDate}
    ''';
  }
}
