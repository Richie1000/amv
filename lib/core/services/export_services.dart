import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/push_list_item.dart';
import '../../models/route_request.dart';

String _smsLabel(SmsRouteType? v) => switch (v) {
  SmsRouteType.direct => 'Direct',
  SmsRouteType.hq => 'HQ',
  SmsRouteType.localBypass => 'Local Bypass',
  SmsRouteType.sim => 'SIM',
  SmsRouteType.casino => 'Casino',
  SmsRouteType.spam => 'Spam',
  SmsRouteType.local => 'Local',
  SmsRouteType.ss7 => 'SS7',
  null => '',
};

String _voiceLabel(VoiceRouteType? v) => switch (v) {
  VoiceRouteType.cli => 'CLI',
  VoiceRouteType.nonCli => 'Non-CLI',
  VoiceRouteType.cc => 'CC',
  VoiceRouteType.tdm => 'TDM',
  null => '',
};

class ExportService {
  ExportService._();
  static final instance = ExportService._();

  /// Exports push list to Excel and returns the saved file path.
  Future<String> exportPushList(List<PushListItem> items) async {
    final excel = Excel.createExcel();
    final sheet = excel['Push List'];

    // ── Remove default sheet ────────────────────────────────────────────────
    excel.delete('Sheet1');

    // ── Header styles ───────────────────────────────────────────────────────
    final headerStyle = CellStyle(
      bold: true,
      fontFamily: getFontFamily(FontFamily.Arial),
      fontSize: 11,
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      backgroundColorHex: ExcelColor.fromHexString('#1C2333'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      textWrapping: TextWrapping.WrapText,
      leftBorder: Border(
        borderStyle: BorderStyle.Thin,
        borderColorHex: ExcelColor.fromHexString('#30363D'),
      ),
      rightBorder: Border(
        borderStyle: BorderStyle.Thin,
        borderColorHex: ExcelColor.fromHexString('#30363D'),
      ),
      bottomBorder: Border(
        borderStyle: BorderStyle.Medium,
        borderColorHex: ExcelColor.fromHexString('#E8A020'),
      ),
    );

    final dataStyle = CellStyle(
      fontFamily: getFontFamily(FontFamily.Arial),
      fontSize: 10,
      fontColorHex: ExcelColor.fromHexString('#000000'),
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
      leftBorder: Border(
        borderStyle: BorderStyle.Thin,
        borderColorHex: ExcelColor.fromHexString('#D0D0D0'),
      ),
      rightBorder: Border(
        borderStyle: BorderStyle.Thin,
        borderColorHex: ExcelColor.fromHexString('#D0D0D0'),
      ),
      bottomBorder: Border(
        borderStyle: BorderStyle.Thin,
        borderColorHex: ExcelColor.fromHexString('#D0D0D0'),
      ),
    );

    final rateStyle = CellStyle(
      fontFamily: getFontFamily(FontFamily.Arial),
      fontSize: 10,
      bold: true,
      fontColorHex: ExcelColor.fromHexString('#000000'),
      horizontalAlign: HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
      leftBorder: Border(
        borderStyle: BorderStyle.Thin,
        borderColorHex: ExcelColor.fromHexString('#D0D0D0'),
      ),
      rightBorder: Border(
        borderStyle: BorderStyle.Thin,
        borderColorHex: ExcelColor.fromHexString('#D0D0D0'),
      ),
      bottomBorder: Border(
        borderStyle: BorderStyle.Thin,
        borderColorHex: ExcelColor.fromHexString('#D0D0D0'),
      ),
    );

    // ── Headers ─────────────────────────────────────────────────────────────
    const headers = ['Destination', 'Network', 'Quality', 'Rate', 'Comments'];

    for (var col = 0; col < headers.length; col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0),
      );
      cell.value = TextCellValue(headers[col]);
      cell.cellStyle = headerStyle;
    }

    // ── Row height for header ────────────────────────────────────────────────
    sheet.setRowHeight(0, 22);

    // ── Data rows ────────────────────────────────────────────────────────────
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final rowIdx = i + 1;

      final quality = item.isSms
          ? _smsLabel(item.smsRouteType)
          : _voiceLabel(item.voiceRouteType);

      final rateLabel =
          '${item.currency} ${item.sellingRate.toStringAsFixed(4)}';

      final values = [
        item.country,
        item.operator,
        quality,
        rateLabel,
        item.comment ?? '',
      ];

      for (var col = 0; col < values.length; col++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIdx),
        );
        cell.value = TextCellValue(values[col]);
        cell.cellStyle = col == 3 ? rateStyle : dataStyle;
      }

      sheet.setRowHeight(rowIdx, 18);

      // Alternating row background
      if (i.isEven) {
        for (var col = 0; col < values.length; col++) {
          final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIdx),
          );
          cell.cellStyle = (col == 3 ? rateStyle : dataStyle).copyWith(
            backgroundColorHexVal: ExcelColor.fromHexString('#F8F9FA'),
          );
        }
      }
    }

    // ── Column widths ─────────────────────────────────────────────────────────
    sheet.setColumnWidth(0, 22); // Destination
    sheet.setColumnWidth(1, 22); // Network
    sheet.setColumnWidth(2, 16); // Quality
    sheet.setColumnWidth(3, 16); // Rate
    sheet.setColumnWidth(4, 35); // Comments

    // ── Save file ────────────────────────────────────────────────────────────
    final dir = Platform.isWindows
        ? await getApplicationDocumentsDirectory()
        : await getApplicationDocumentsDirectory();

    final timestamp = DateTime.now();
    final filename =
        'PushList_${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}'
        '_${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}.xlsx';

    final file = File('${dir.path}/$filename');
    final bytes = excel.encode()!;
    await file.writeAsBytes(bytes);

    return file.path;
  }
}
