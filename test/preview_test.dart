import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pendart/editor.dart';

void main() {
  group('PendartEditor Preview Mode', () {
    testWidgets('toggles between edit and preview mode correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PendartEditor(
            initialText: 'Test content',
          ),
        ),
      ));

      // Initially in edit mode - should see TextField
      expect(find.byType(TextField), findsOneWidget);

      // Find and tap preview button (using icon)
      final previewButton = find.byIcon(Icons.visibility);
      await tester.tap(previewButton);
      await tester.pump();

      // Now in preview mode - TextField should be gone, SingleChildScrollView for preview is visible
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(SingleChildScrollView),
          findsNWidgets(2)); // Toolbar + Preview area

      // Find and tap edit button (now showing edit icon)
      final editButton = find.byIcon(Icons.edit);
      await tester.tap(editButton);
      await tester.pump();

      // Back to edit mode
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('preview mode renders simple text correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PendartEditor(
            initialText: 'Simple text',
          ),
        ),
      ));

      // Switch to preview mode
      final previewButton = find.byIcon(Icons.visibility);
      await tester.tap(previewButton);
      await tester.pump();

      // Text should be visible in preview
      expect(find.text('Simple text'), findsOneWidget);
    });

    testWidgets('preview mode renders headings correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PendartEditor(
            initialText: '! Heading 1\n!! Heading 2',
          ),
        ),
      ));

      // Switch to preview mode
      final previewButton = find.byIcon(Icons.visibility);
      await tester.tap(previewButton);
      await tester.pump();

      // Headings should be visible in preview
      expect(find.text('Heading 1'), findsOneWidget);
      expect(find.text('Heading 2'), findsOneWidget);
    });

    testWidgets('preview mode renders checkboxes correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PendartEditor(
            initialText: '[] Unchecked task\n[x] Checked task',
          ),
        ),
      ));

      // Switch to preview mode
      final previewButton = find.byIcon(Icons.visibility);
      await tester.tap(previewButton);
      await tester.pump();

      // Checkbox content should be visible
      expect(find.text('Unchecked task'), findsOneWidget);
      expect(find.text('Checked task'), findsOneWidget);

      // Find checkboxes (need to look for Row widgets containing Checkbox)
      expect(find.byType(Checkbox), findsNWidgets(2));

      // Verify checkbox states
      final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox));
      expect(checkboxes.first.value, false);
      expect(checkboxes.last.value, true);
    });

    testWidgets('checkboxes in preview mode call onCheckboxChanged',
        (WidgetTester tester) async {
      int? changedIndex;
      bool? changedValue;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PendartEditor(
            initialText: '[] Task item',
            onCheckboxChanged: (index, value) {
              changedIndex = index;
              changedValue = value;
            },
          ),
        ),
      ));

      // Switch to preview mode
      final previewButton = find.byIcon(Icons.visibility);
      await tester.tap(previewButton);
      await tester.pump();

      // Find and tap the checkbox
      final checkbox = find.byType(Checkbox).first;
      await tester.tap(checkbox);
      await tester.pump();

      // Verify callback was called
      expect(changedIndex, isNotNull);
      expect(changedValue, true);
    });

    testWidgets('editor updates preview when text changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PendartEditor(
            initialText: 'Initial text',
          ),
        ),
      ));

      // Enter new text in edit mode
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Updated text');
      await tester.pump();

      // Switch to preview mode
      final previewButton = find.byIcon(Icons.visibility);
      await tester.tap(previewButton);
      await tester.pump();

      // Updated text should be visible in preview
      expect(find.text('Updated text'), findsOneWidget);
      expect(find.text('Initial text'), findsNothing);
    });
  });
}
