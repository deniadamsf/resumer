import 'package:flutter_test/flutter_test.dart';
import 'package:resumer/core/services/document_text_extractor_service.dart';

void main() {
  test('ExtractedDocumentResult accurately calculates length and content status', () {
    const validDoc = ExtractedDocumentResult(
      fileName: 'Curriculum_Vitae.pdf',
      extension: 'pdf',
      fileSizeBytes: 2048,
      text: 'Alexander Wright\nSoftware Engineer\n5+ years of Flutter and Mobile Experience',
    );

    expect(validDoc.characterCount, greaterThan(40));
    expect(validDoc.hasContent, isTrue);

    const emptyDoc = ExtractedDocumentResult(
      fileName: 'Empty.docx',
      extension: 'docx',
      fileSizeBytes: 100,
      text: 'Too short',
    );

    expect(emptyDoc.hasContent, isFalse);
  });
}
