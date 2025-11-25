import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:typed_data';

class WebHelpers {
  // Register PDF viewer for Flutter Web
  static void registerPdfViewer(String viewId, Uint8List pdfBytes) {
    final base64 = base64Encode(pdfBytes);
    final dataUrl = 'data:application/pdf;base64,$base64';
    
    // Register view factory
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = dataUrl
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        return iframe;
      },
    );
  }

  // Download file in browser
  static void downloadFile(Uint8List bytes, String fileName) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}