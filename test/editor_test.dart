import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pendart/editor.dart';

void main() {
  group('PendartEditor', () {
    testWidgets('initializes with given text', (WidgetTester tester) async {
      const initialText = 'Test content';

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PendartEditor(
            initialText: initialText,
          ),
        ),
      ));

      // Find the TextField
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Check if the text is set correctly
      expect(find.text(initialText), findsOneWidget);
    });

    testWidgets('toggles between edit and preview mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PendartEditor(),
        ),
      ));

      // Initially in edit mode
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget); // For toolbar

      // Find and tap the preview toggle button
      final previewButton = find.byTooltip('Preview');
      await tester.tap(previewButton);
      await tester.pump();

      // Should be in preview mode now
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(SingleChildScrollView),
          findsNWidgets(2)); // For toolbar and preview

      // Tap the edit button to go back
      final editButton = find.byTooltip('Edit');
      await tester.tap(editButton);
      await tester.pump();

      // Should be back in edit mode
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('calls onTextChanged callback when text changes',
        (WidgetTester tester) async {
      String changedText = '';

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PendartEditor(
            onTextChanged: (text) {
              changedText = text;
            },
          ),
        ),
      ));

      // Find the TextField and enter text
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Updated text');

      // Check if callback was called with correct text
      expect(changedText, 'Updated text');
    });

    testWidgets('applies bold formatting', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PendartEditor(),
        ),
      ));

      // Find the TextField and set selection
      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pump();

      // Find and tap bold button
      final boldButton = find.byTooltip('Bold');
      await tester.tap(boldButton);
      await tester.pump();

      // Get the current text
      final TextField textFieldWidget = tester.widget(textField);
      final TextEditingController controller = textFieldWidget.controller!;

      // Check if bold formatting was applied
      expect(controller.text, '**bold text**');
    });

    testWidgets('applies italic formatting', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PendartEditor(),
        ),
      ));

      // Find the TextField and set selection
      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pump();

      // Find and tap italic button
      final italicButton = find.byTooltip('Italic');
      await tester.tap(italicButton);
      await tester.pump();

      // Get the current text
      final TextField textFieldWidget = tester.widget(textField);
      final TextEditingController controller = textFieldWidget.controller!;

      // Check if italic formatting was applied
      expect(controller.text, '%%italic text%%');
    });

    testWidgets('applies heading formatting', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PendartEditor(),
        ),
      ));

      // Find the TextField and set selection
      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pump();

      // Find and tap H1 button
      final h1Button = find.byTooltip('Heading 1');
      await tester.tap(h1Button);
      await tester.pump();

      // Get the current text
      final TextField textFieldWidget = tester.widget(textField);
      final TextEditingController controller = textFieldWidget.controller!;

      // Check if H1 formatting was applied
      expect(controller.text, '! Heading 1');
    });

    testWidgets('applies checkbox formatting', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PendartEditor(),
        ),
      ));

      // Find the TextField and set selection
      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pump();

      // Find and tap unchecked checkbox button
      final checkboxButton = find.byTooltip('Unchecked Checkbox');
      await tester.tap(checkboxButton);
      await tester.pump();

      // Get the current text
      final TextField textFieldWidget = tester.widget(textField);
      final TextEditingController controller = textFieldWidget.controller!;

      // Check if checkbox formatting was applied
      expect(controller.text, '[] Task item\n');
    });

    testWidgets('wraps selected text with formatting',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PendartEditor(
            initialText: 'Selected text',
          ),
        ),
      ));

      // Find the TextField and enter text
      final textField = find.byType(TextField);

      // This part is tricky in widget tests - simulating selection
      final TextField textFieldWidget = tester.widget(textField);
      final TextEditingController controller = textFieldWidget.controller!;

      // Manually set selection
      controller.selection = const TextSelection(
        baseOffset: 0,
        extentOffset: 13, // Selects "Selected text"
      );

      // Find and tap bold button
      final boldButton = find.byTooltip('Bold');
      await tester.tap(boldButton);
      await tester.pump();

      // Check if selected text was wrapped with formatting
      expect(controller.text, '**Selected text**');
    });

    testWidgets('handles checkbox change callbacks',
        (WidgetTester tester) async {
      int? changedIndex;
      bool? changedValue;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PendartEditor(
            initialText: '[] Test task',
            onCheckboxChanged: (index, value) {
              changedIndex = index;
              changedValue = value;
            },
          ),
        ),
      ));

      // Switch to preview mode
      final previewButton = find.byTooltip('Preview');
      await tester.tap(previewButton);
      await tester.pump();

      // Enter text with a checkbox
      await tester.enterText(find.byType(TextField), '[] Task Item');
      await tester.pumpAndSettle();

      // First, verify that checkboxes are present in the preview
      final previewFinder = find.byKey(Key('pendart_preview'));
      expect(previewFinder, findsOneWidget);

      // Use the Finder API to find the checkbox directly
      final checkboxFinder = find.descendant(
        of: previewFinder,
        matching: find.byType(Checkbox),
      );

      expect(checkboxFinder, findsWidgets);

      // Get the first checkbox and trigger its onChanged callback
      final checkbox = tester.widget<Checkbox>(checkboxFinder.first);
      checkbox.onChanged?.call(true);

      // Verify the callback was triggered
      expect(changedIndex, isNotNull);
      expect(changedValue, isTrue);
    });
  });

  // Additional test group for helper methods and edge cases
  group('PendartEditor helper methods', () {
    testWidgets('horizontal rule adds proper markup',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PendartEditor(),
        ),
      ));

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pump();

      final hrButton = find.byTooltip('Horizontal Rule');
      await tester.tap(hrButton);
      await tester.pump();

      final TextField textFieldWidget = tester.widget(textField);
      final TextEditingController controller = textFieldWidget.controller!;

      expect(controller.text, '---\n');
    });

    testWidgets('link formatting adds proper markup',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PendartEditor(),
        ),
      ));

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pump();

      final linkButton = find.byTooltip('Link');
      await tester.tap(linkButton);
      await tester.pump();

      final TextField textFieldWidget = tester.widget(textField);
      final TextEditingController controller = textFieldWidget.controller!;

      expect(controller.text, '@@https://example.com@@');
    });
  });
}
