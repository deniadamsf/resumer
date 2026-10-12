import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:xml/xml.dart';

/// Hasil ekstraksi dokumen lokal di sisi klien (100% offline di perangkat)
class ExtractedDocumentResult {
  final String fileName;
  final String extension;
  final int fileSizeBytes;
  final String text;

  const ExtractedDocumentResult({
    required this.fileName,
    required this.extension,
    required this.fileSizeBytes,
    required this.text,
  });

  int get characterCount => text.length;
  bool get hasContent => text.trim().length >= 40;
}

/// Service untuk membaca dan mengekstrak teks dokumen PDF & DOCX secara 100% lokal di HP pengguna.
/// Berkas biner TIDAK PERNAH diunggah ke server, menjamin keamanan privasi dan zero load di server.
class DocumentTextExtractorService {
  static final DocumentTextExtractorService instance = DocumentTextExtractorService._internal();
  DocumentTextExtractorService._internal();

  /// Membuka file picker untuk memilih file CV (.pdf, .docx, .doc, .txt)
  /// dan mengekstrak teksnya secara lokal di memori HP.
  Future<ExtractedDocumentResult?> pickAndExtractText() async {
    try {
      final platformFile = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc', 'txt'],
      );

      if (platformFile == null) {
        return null; // Pengguna membatalkan
      }
      final fileName = platformFile.name;
      final ext = platformFile.extension?.toLowerCase() ?? '';

      final bytes = await platformFile.readAsBytes();

      String extractedText = '';

      if (ext == 'pdf') {
        extractedText = _extractTextFromPdfBytes(bytes);
      } else if (ext == 'docx') {
        extractedText = _extractTextFromDocxBytes(bytes);
      } else if (ext == 'txt') {
        extractedText = utf8.decode(bytes, allowMalformed: true);
      } else if (ext == 'doc') {
        // .doc biner lama (Word 97-2003): Coba decode teks ASCII/UTF8 dengan filter
        extractedText = _extractTextFromLegacyDocBytes(bytes);
      } else {
        throw Exception('Format .$ext belum didukung. Harap pilih berkas PDF atau DOCX.');
      }

      final cleanText = _sanitizeExtractedText(extractedText);

      return ExtractedDocumentResult(
        fileName: fileName,
        extension: ext,
        fileSizeBytes: bytes.length,
        text: cleanText,
      );
    } catch (e) {
      debugPrint('[DocumentTextExtractorService] Error: $e');
      rethrow;
    }
  }

  /// Ekstraksi teks dari PDF menggunakan engine lokal Syncfusion
  String _extractTextFromPdfBytes(Uint8List bytes) {
    PdfDocument? document;
    try {
      document = PdfDocument(inputBytes: bytes);
      final textExtractor = PdfTextExtractor(document);
      final extracted = textExtractor.extractText();
      
      if (extracted.trim().isEmpty) {
        throw Exception(
          'Dokumen PDF ini tidak memiliki lapisan teks yang dapat dibaca (kemungkinan hasil scan gambar/foto). '
          'Silakan gunakan PDF teks atau berkas DOCX.'
        );
      }
      return extracted;
    } finally {
      document?.dispose();
    }
  }

  /// Ekstraksi teks dari berkas DOCX (Microsoft Word modern)
  /// DOCX adalah ZIP archive yang berisi XML di `word/document.xml`
  String _extractTextFromDocxBytes(Uint8List bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      ArchiveFile? docXmlFile;

      for (final file in archive) {
        if (file.name == 'word/document.xml') {
          docXmlFile = file;
          break;
        }
      }

      if (docXmlFile == null) {
        throw Exception('Berkas DOCX tidak valid atau rusak (word/document.xml tidak ditemukan).');
      }

      final xmlString = utf8.decode(docXmlFile.content as List<int>, allowMalformed: true);
      final xmlDoc = XmlDocument.parse(xmlString);

      // Cari semua paragraf <w:p>
      final paragraphs = xmlDoc.findAllElements('w:p');
      final buffer = StringBuffer();

      for (final p in paragraphs) {
        final textElements = p.findAllElements('w:t');
        final pBuffer = StringBuffer();
        for (final t in textElements) {
          pBuffer.write(t.innerText);
        }
        final pText = pBuffer.toString().trim();
        if (pText.isNotEmpty) {
          buffer.writeln(pText);
        }
      }

      final result = buffer.toString();
      if (result.trim().isEmpty) {
        throw Exception('Berkas DOCX tidak memiliki teks yang terbaca.');
      }
      return result;
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Gagal membaca isi berkas DOCX: $e');
    }
  }

  /// Ekstraksi fallback untuk format .doc warisan (Word 97-2003)
  String _extractTextFromLegacyDocBytes(Uint8List bytes) {
    // Cari blok teks terenkapsulasi string printable
    final raw = utf8.decode(bytes, allowMalformed: true);
    final buffer = StringBuffer();
    final lines = raw.split(RegExp(r'[\r\n]+'));

    for (final line in lines) {
      final printable = line.replaceAll(RegExp(r'[^\x20-\x7E\u00A0-\u00FF\u0100-\u017F]+'), ' ').trim();
      if (printable.length > 5 && printable.contains(' ')) {
        buffer.writeln(printable);
      }
    }

    final res = buffer.toString().trim();
    if (res.length < 50) {
      throw Exception('Format .doc warisan tidak dapat diekstrak secara akurat. Harap simpan ulang berkas sebagai .docx atau .pdf.');
    }
    return res;
  }

  /// Membersihkan teks dari spasi ganda berlebih dan karakter tak terlihat
  String _sanitizeExtractedText(String text) {
    return text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
        .trim();
  }
}
