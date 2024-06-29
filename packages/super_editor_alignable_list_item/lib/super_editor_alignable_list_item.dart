library super_editor_alignable_list_item;

import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';

class AlignableListItemComponentBuilder implements ComponentBuilder {
  const AlignableListItemComponentBuilder();

  @override
  SingleColumnLayoutComponentViewModel? createViewModel(Document document, DocumentNode node) {
    if (node is! ListItemNode) {
      return null;
    }

    int? ordinalValue;
    if (node.type == ListItemType.ordered) {
      ordinalValue = computeListItemOrdinalValue(node, document);
    }

    final textDirection = getParagraphDirection(node.text.text);

    TextAlign textAlign = (textDirection == TextDirection.ltr) ? TextAlign.left : TextAlign.right;
    final textAlignName = node.getMetadataValue('textAlign');
    switch (textAlignName) {
      case 'left':
        textAlign = TextAlign.left;
        break;
      case 'center':
        textAlign = TextAlign.center;
        break;
      case 'right':
        textAlign = TextAlign.right;
        break;
      case 'justify':
        textAlign = TextAlign.justify;
        break;
    }

    return switch (node.type) {
      ListItemType.unordered => AlignableUnorderedListItemComponentViewModel(
          nodeId: node.id,
          indent: node.indent,
          text: node.text,
          textDirection: textDirection,
          textAlignment: textAlign,
          textStyleBuilder: noStyleBuilder,
          selectionColor: const Color(0x00000000),
        ),
      ListItemType.ordered => AlignableOrderedListItemComponentViewModel(
          nodeId: node.id,
          indent: node.indent,
          ordinalValue: ordinalValue,
          text: node.text,
          textDirection: textDirection,
          textAlignment: textAlign,
          textStyleBuilder: noStyleBuilder,
          selectionColor: const Color(0x00000000),
        ),
    };
  }

  @override
  Widget? createComponent(
      SingleColumnDocumentComponentContext componentContext, SingleColumnLayoutComponentViewModel componentViewModel) {
    if (componentViewModel is! AlignableUnorderedListItemComponentViewModel &&
        componentViewModel is! AlignableOrderedListItemComponentViewModel) {
      return null;
    }

    if (componentViewModel is AlignableUnorderedListItemComponentViewModel) {
      return AlignableUnorderedListItemComponent(
        componentKey: componentContext.componentKey,
        text: componentViewModel.text,
        textDirection: componentViewModel.textDirection,
        textAlignment: componentViewModel.textAlignment,
        styleBuilder: componentViewModel.textStyleBuilder,
        indent: componentViewModel.indent,
        dotStyle: componentViewModel.dotStyle,
        textSelection: componentViewModel.selection,
        selectionColor: componentViewModel.selectionColor,
        highlightWhenEmpty: componentViewModel.highlightWhenEmpty,
        composingRegion: componentViewModel.composingRegion,
        showComposingUnderline: componentViewModel.showComposingUnderline,
      );
    } else if (componentViewModel is AlignableOrderedListItemComponentViewModel) {
      return AlignableOrderedListItemComponent(
        componentKey: componentContext.componentKey,
        indent: componentViewModel.indent,
        listIndex: componentViewModel.ordinalValue!,
        text: componentViewModel.text,
        textDirection: componentViewModel.textDirection,
        textAlignment: componentViewModel.textAlignment,
        styleBuilder: componentViewModel.textStyleBuilder,
        numeralStyle: componentViewModel.numeralStyle,
        textSelection: componentViewModel.selection,
        selectionColor: componentViewModel.selectionColor,
        highlightWhenEmpty: componentViewModel.highlightWhenEmpty,
        composingRegion: componentViewModel.composingRegion,
        showComposingUnderline: componentViewModel.showComposingUnderline,
      );
    }

    editorLayoutLog
        .warning("Tried to build a component for a list item view model without a list item type: $componentViewModel");
    return null;
  }
}

class AlignableUnorderedListItemComponentViewModel extends ListItemComponentViewModel {
  AlignableUnorderedListItemComponentViewModel({
    required super.nodeId,
    super.maxWidth,
    super.padding = EdgeInsets.zero,
    required super.indent,
    required super.text,
    required super.textStyleBuilder,
    this.dotStyle = const ListItemDotStyle(),
    super.textDirection = TextDirection.ltr,
    super.textAlignment = TextAlign.left,
    super.selection,
    required super.selectionColor,
    super.highlightWhenEmpty = false,
    super.composingRegion,
    super.showComposingUnderline = false,
  });

  ListItemDotStyle dotStyle = const ListItemDotStyle();

  @override
  void applyStyles(Map<String, dynamic> styles) {
    super.applyStyles(styles);
    dotStyle = ListItemDotStyle(
      color: styles[Styles.dotColor],
      shape: styles[Styles.dotShape] ?? BoxShape.circle,
      size: styles[Styles.dotSize] ?? const Size(4, 4),
    );
  }

  @override
  AlignableUnorderedListItemComponentViewModel copy() {
    return AlignableUnorderedListItemComponentViewModel(
      nodeId: nodeId,
      maxWidth: maxWidth,
      padding: padding,
      indent: indent,
      text: text,
      textStyleBuilder: textStyleBuilder,
      dotStyle: dotStyle,
      textDirection: textDirection,
      textAlignment: textAlignment,
      selection: selection,
      selectionColor: selectionColor,
      composingRegion: composingRegion,
      showComposingUnderline: showComposingUnderline,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is AlignableUnorderedListItemComponentViewModel &&
          runtimeType == other.runtimeType &&
          dotStyle == other.dotStyle;

  @override
  int get hashCode => super.hashCode ^ dotStyle.hashCode;
}

class AlignableOrderedListItemComponentViewModel extends ListItemComponentViewModel {
  AlignableOrderedListItemComponentViewModel({
    required super.nodeId,
    super.maxWidth,
    super.padding = EdgeInsets.zero,
    required super.indent,
    this.ordinalValue,
    this.numeralStyle = OrderedListNumeralStyle.arabic,
    required super.text,
    required super.textStyleBuilder,
    super.textDirection = TextDirection.ltr,
    super.textAlignment = TextAlign.left,
    super.selection,
    required super.selectionColor,
    super.highlightWhenEmpty = false,
    super.composingRegion,
    super.showComposingUnderline = false,
  });

  final int? ordinalValue;
  OrderedListNumeralStyle numeralStyle;

  @override
  void applyStyles(Map<String, dynamic> styles) {
    super.applyStyles(styles);
    numeralStyle = styles[Styles.listNumeralStyle] ?? OrderedListNumeralStyle.arabic;
  }

  @override
  AlignableOrderedListItemComponentViewModel copy() {
    return AlignableOrderedListItemComponentViewModel(
      nodeId: nodeId,
      maxWidth: maxWidth,
      padding: padding,
      indent: indent,
      ordinalValue: ordinalValue,
      numeralStyle: numeralStyle,
      text: text,
      textStyleBuilder: textStyleBuilder,
      textDirection: textDirection,
      textAlignment: textAlignment,
      selection: selection,
      selectionColor: selectionColor,
      composingRegion: composingRegion,
      showComposingUnderline: showComposingUnderline,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is AlignableOrderedListItemComponentViewModel &&
          runtimeType == other.runtimeType &&
          ordinalValue == other.ordinalValue &&
          numeralStyle == other.numeralStyle;

  @override
  int get hashCode => super.hashCode ^ ordinalValue.hashCode ^ numeralStyle.hashCode;
}

class AlignableUnorderedListItemComponent extends StatefulWidget {
  const AlignableUnorderedListItemComponent({
    Key? key,
    required this.componentKey,
    required this.text,
    required this.styleBuilder,
    this.textDirection = TextDirection.ltr,
    this.textAlignment = TextAlign.left,
    this.dotBuilder = _defaultUnorderedListItemDotBuilder,
    this.dotStyle,
    this.indent = 0,
    this.indentCalculator = defaultListItemIndentCalculator,
    this.textSelection,
    this.selectionColor = Colors.lightBlueAccent,
    this.showCaret = false,
    this.caretColor = Colors.black,
    this.highlightWhenEmpty = false,
    this.composingRegion,
    this.showComposingUnderline = false,
    this.showDebugPaint = false,
  }) : super(key: key);

  final GlobalKey componentKey;
  final AttributedText text;
  final TextDirection textDirection;
  final TextAlign textAlignment;
  final AttributionStyleBuilder styleBuilder;
  final AlignableUnorderedListItemDotBuilder dotBuilder;
  final ListItemDotStyle? dotStyle;
  final int indent;
  final double Function(TextStyle, int indent) indentCalculator;
  final TextSelection? textSelection;
  final Color selectionColor;
  final bool showCaret;
  final Color caretColor;
  final bool highlightWhenEmpty;
  final TextRange? composingRegion;
  final bool showComposingUnderline;
  final bool showDebugPaint;

  @override
  State<AlignableUnorderedListItemComponent> createState() => _AlignableUnorderedListItemComponentState();
}

class _AlignableUnorderedListItemComponentState extends State<AlignableUnorderedListItemComponent> {
  /// A [GlobalKey] that connects a [ProxyTextDocumentComponent] to its
  /// descendant [TextComponent].
  ///
  /// The [ProxyTextDocumentComponent] doesn't know where the [TextComponent] sits
  /// in its subtree, but the proxy needs access to the [TextComponent] to provide
  /// access to text layout details.
  ///
  /// This key doesn't need to be public because the given [widget.componentKey]
  /// provides clients with direct access to text layout queries, as well as
  /// standard [DocumentComponent] queries.
  final GlobalKey _innerTextComponentKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // Usually, the font size is obtained via the stylesheet. But the attributions might
    // also contain a FontSizeAttribution, which overrides the stylesheet. Use the attributions
    // of the first character to determine the text style.
    final attributions = widget.text.getAllAttributionsAt(0).toSet();
    final textStyle = widget.styleBuilder(attributions);

    final indentSpace = widget.indentCalculator(textStyle, widget.indent);
    final textScaler = MediaQuery.textScalerOf(context);
    final lineHeight = textScaler.scale(textStyle.fontSize! * (textStyle.height ?? 1.25));

    return ProxyTextDocumentComponent(
      key: widget.componentKey,
      textComponentKey: _innerTextComponentKey,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: indentSpace,
            decoration: BoxDecoration(
              border: widget.showDebugPaint ? Border.all(width: 1, color: Colors.grey) : null,
            ),
            child: SizedBox(
              height: lineHeight,
              child: widget.dotBuilder(context, widget),
            ),
          ),
          Expanded(
            child: TextComponent(
              key: _innerTextComponentKey,
              text: widget.text,
              textAlign: widget.textAlignment,
              textDirection: widget.textDirection,
              textStyleBuilder: widget.styleBuilder,
              textSelection: widget.textSelection,
              textScaler: textScaler,
              selectionColor: widget.selectionColor,
              highlightWhenEmpty: widget.highlightWhenEmpty,
              composingRegion: widget.composingRegion,
              showComposingUnderline: widget.showComposingUnderline,
              showDebugPaint: widget.showDebugPaint,
            ),
          ),
        ],
      ),
    );
  }
}

typedef AlignableUnorderedListItemDotBuilder = Widget Function(BuildContext, AlignableUnorderedListItemComponent);

Widget _defaultUnorderedListItemDotBuilder(BuildContext context, AlignableUnorderedListItemComponent component) {
  // Usually, the font size is obtained via the stylesheet. But the attributions might
  // also contain a FontSizeAttribution, which overrides the stylesheet. Use the attributions
  // of the first character to determine the text style.
  final attributions = component.text.getAllAttributionsAt(0).toSet();
  final textStyle = component.styleBuilder(attributions);

  final dotSize = component.dotStyle?.size ?? const Size(4, 4);

  return Align(
    alignment: Alignment.centerRight,
    child: Text.rich(
      TextSpan(
        // Place a zero-width joiner before the bullet point to make it properly aligned. Without this,
        // the bullet point is not vertically centered with the text, even when setting the textStyle
        // on the whole rich text or WidgetSpan.
        text: '\u200C',
        style: textStyle,
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              width: dotSize.width,
              height: dotSize.height,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                shape: component.dotStyle?.shape ?? BoxShape.circle,
                color: component.dotStyle?.color ?? textStyle.color,
              ),
            ),
          ),
        ],
      ),
      // Don't scale the dot.
      textScaler: const TextScaler.linear(1.0),
    ),
  );
}

class AlignableOrderedListItemComponent extends StatefulWidget {
  const AlignableOrderedListItemComponent({
    Key? key,
    required this.componentKey,
    required this.listIndex,
    required this.text,
    required this.styleBuilder,
    this.textDirection = TextDirection.ltr,
    this.textAlignment = TextAlign.left,
    this.numeralBuilder = _defaultOrderedListItemNumeralBuilder,
    this.numeralStyle = OrderedListNumeralStyle.arabic,
    this.indent = 0,
    this.indentCalculator = defaultListItemIndentCalculator,
    this.textSelection,
    this.selectionColor = Colors.lightBlueAccent,
    this.showCaret = false,
    this.caretColor = Colors.black,
    this.highlightWhenEmpty = false,
    this.composingRegion,
    this.showComposingUnderline = false,
    this.showDebugPaint = false,
  }) : super(key: key);

  final GlobalKey componentKey;
  final int listIndex;
  final AttributedText text;
  final TextDirection textDirection;
  final TextAlign textAlignment;
  final AttributionStyleBuilder styleBuilder;
  final AlignableOrderedListItemNumeralBuilder numeralBuilder;
  final OrderedListNumeralStyle numeralStyle;
  final int indent;
  final TextBlockIndentCalculator indentCalculator;
  final TextSelection? textSelection;
  final Color selectionColor;
  final bool showCaret;
  final Color caretColor;
  final bool highlightWhenEmpty;
  final TextRange? composingRegion;
  final bool showComposingUnderline;
  final bool showDebugPaint;

  @override
  State<AlignableOrderedListItemComponent> createState() => _AlignableOrderedListItemComponentState();
}

class _AlignableOrderedListItemComponentState extends State<AlignableOrderedListItemComponent> {
  /// A [GlobalKey] that connects a [ProxyTextDocumentComponent] to its
  /// descendant [TextComponent].
  ///
  /// The [ProxyTextDocumentComponent] doesn't know where the [TextComponent] sits
  /// in its subtree, but the proxy needs access to the [TextComponent] to provide
  /// access to text layout details.
  ///
  /// This key doesn't need to be public because the given [widget.componentKey]
  /// provides clients with direct access to text layout queries, as well as
  /// standard [DocumentComponent] queries.
  final GlobalKey _innerTextComponentKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // Usually, the font size is obtained via the stylesheet. But the attributions might
    // also contain a FontSizeAttribution, which overrides the stylesheet. Use the attributions
    // of the first character to determine the text style.
    final attributions = widget.text.getAllAttributionsAt(0).toSet();
    final textStyle = widget.styleBuilder(attributions);

    final indentSpace = widget.indentCalculator(textStyle, widget.indent);
    final textScaler = MediaQuery.textScalerOf(context);
    final lineHeight = textScaler.scale(textStyle.fontSize! * (textStyle.height ?? 1.0));

    return ProxyTextDocumentComponent(
      key: widget.componentKey,
      textComponentKey: _innerTextComponentKey,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: indentSpace,
            height: lineHeight,
            decoration: BoxDecoration(
              border: widget.showDebugPaint ? Border.all(width: 1, color: Colors.grey) : null,
            ),
            child: SizedBox(
              height: lineHeight,
              child: widget.numeralBuilder(context, widget),
            ),
          ),
          Expanded(
            child: TextComponent(
              key: _innerTextComponentKey,
              text: widget.text,
              textAlign: widget.textAlignment,
              textDirection: widget.textDirection,
              textStyleBuilder: widget.styleBuilder,
              textSelection: widget.textSelection,
              textScaler: textScaler,
              selectionColor: widget.selectionColor,
              highlightWhenEmpty: widget.highlightWhenEmpty,
              composingRegion: widget.composingRegion,
              showComposingUnderline: widget.showComposingUnderline,
              showDebugPaint: widget.showDebugPaint,
            ),
          ),
        ],
      ),
    );
  }
}

typedef AlignableOrderedListItemNumeralBuilder = Widget Function(BuildContext, AlignableOrderedListItemComponent);

Widget _defaultOrderedListItemNumeralBuilder(BuildContext context, AlignableOrderedListItemComponent component) {
  // Usually, the font size is obtained via the stylesheet. But the attributions might
  // also contain a FontSizeAttribution, which overrides the stylesheet. Use the attributions
  // of the first character to determine the text style.
  final attributions = component.text.getAllAttributionsAt(0).toSet();
  final textStyle = component.styleBuilder(attributions);

  return OverflowBox(
    maxWidth: double.infinity,
    maxHeight: double.infinity,
    child: Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 5.0),
        child: Text(
          '${_numeralForIndex(component.listIndex, component.numeralStyle)}.',
          textAlign: TextAlign.right,
          style: textStyle,
        ),
      ),
    ),
  );
}

/// Returns the text to be displayed for the given [numeral] and [numeralStyle].
String _numeralForIndex(int numeral, OrderedListNumeralStyle numeralStyle) {
  return switch (numeralStyle) {
    OrderedListNumeralStyle.arabic => '$numeral',
    OrderedListNumeralStyle.upperRoman => _intToRoman(numeral) ?? '$numeral',
    OrderedListNumeralStyle.lowerRoman => _intToRoman(numeral)?.toLowerCase() ?? '$numeral',
    OrderedListNumeralStyle.upperAlpha => _intToAlpha(numeral),
    OrderedListNumeralStyle.lowerAlpha => _intToAlpha(numeral).toLowerCase(),
  };
}

/// Converts a number to its Roman numeral representation.
///
/// Returns `null` if the number is greater than 3999, as we don't support the
/// vinculum notation. See more at https://en.wikipedia.org/wiki/Roman_numerals#cite_ref-Ifrah2000_52-1.
String? _intToRoman(int number) {
  if (number <= 0) {
    throw ArgumentError('Roman numerals are only defined for positive integers');
  }

  if (number > 3999) {
    // Starting from 4000, the Roman numeral representation uses a bar over the numeral to represent
    // a multiplication by 1000. We don't support this notation.
    return null;
  }

  const values = [1000, 500, 100, 50, 10, 5, 1];
  const symbols = ["M", "D", "C", "L", "X", "V", "I"];

  int remainingValueToConvert = number;

  final result = StringBuffer();

  for (int i = 0; i < values.length; i++) {
    final currentSymbol = symbols[i];
    final currentSymbolValue = values[i];

    final count = remainingValueToConvert ~/ currentSymbolValue;

    if (count > 0 && count < 4) {
      // The number is bigger than the current symbol's value. Add the appropriate
      // number of digits, respecting the maximum of three consecutive symbols.
      // For example, for 300 we would add "CCC", but for 400 we won't add "CCCC".
      result.write(currentSymbol * count);

      remainingValueToConvert %= currentSymbolValue;
    }

    if (remainingValueToConvert <= 0) {
      // The conversion is complete.
      break;
    }

    // We still have some value to convert. Check if we can use subtractive notation.
    if (i % 2 == 0 && i + 2 < values.length) {
      // Numbers in even positions (0, 2, 4) can be subtracted with other numbers
      // two positions to the right of them:
      //
      //  - 1000 (M) can be subtracted with 100 (C).
      //  - 100 (C) can be subtracted with 10 (X).
      //  - 10 (X) can be subtracted with 1 (I).
      //
      // Check if we can do this subtraction.
      final subtractiveValue = currentSymbolValue - values[i + 2];
      if (remainingValueToConvert >= subtractiveValue) {
        result.write(symbols[i + 2] + currentSymbol);
        remainingValueToConvert -= subtractiveValue;
      }
    } else if (i % 2 != 0 && i + 1 < values.length) {
      // Numbers in odd positions (1, 3, 5) can be subtracted with the number
      // immediately after it to the right:
      //
      // - 500 (D) can be subtracted with 100 (C).
      // - 50 (L) can be subtracted with 10 (X).
      // - 5 (V) can be subtracted with 1 (I).
      //
      // Check if we can do this subtraction.
      final subtractiveValue = currentSymbolValue - values[i + 1];
      if (remainingValueToConvert >= subtractiveValue) {
        result.write(symbols[i + 1] + currentSymbol);
        remainingValueToConvert -= subtractiveValue;
      }
    }
  }

  return result.toString();
}

/// Converts a number to a string composed of A-Z characters.
///
/// For example:
/// - 1 -> A
/// - 2 -> B
/// - ...
/// - 26 -> Z
/// - 27 -> AA
/// - 28 -> AB
String _intToAlpha(int num) {
  const characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  const base = characters.length;

  String result = '';

  while (num > 0) {
    // Convert to 0-based index.
    num -= 1;

    // Find the next character to be added.
    result = characters[num % base] + result;

    // Move to the next digit.
    num = num ~/ base;
  }

  return result;
}

class ChangeListItemAlignmentRequest implements EditRequest {
  ChangeListItemAlignmentRequest({
    required this.nodeId,
    required this.alignment,
  });

  final String nodeId;
  final TextAlign alignment;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChangeListItemAlignmentRequest &&
          runtimeType == other.runtimeType &&
          nodeId == other.nodeId &&
          alignment == other.alignment;

  @override
  int get hashCode => nodeId.hashCode ^ alignment.hashCode;
}

class ChangeListItemAlignmentCommand implements EditCommand {
  const ChangeListItemAlignmentCommand({
    required this.nodeId,
    required this.alignment,
  });

  final String nodeId;
  final TextAlign alignment;

  @override
  void execute(EditContext context, CommandExecutor executor) {
    final document = context.find<MutableDocument>(Editor.documentKey);

    final existingNode = document.getNodeById(nodeId)! as ListItemNode;

    String? alignmentName;
    switch (alignment) {
      case TextAlign.left:
      case TextAlign.start:
        alignmentName = 'left';
        break;
      case TextAlign.center:
        alignmentName = 'center';
        break;
      case TextAlign.right:
      case TextAlign.end:
        alignmentName = 'right';
        break;
      case TextAlign.justify:
        alignmentName = 'justify';
        break;
    }
    existingNode.putMetadataValue('textAlign', alignmentName);

    executor.logChanges([
      DocumentEdit(
        NodeChangeEvent(nodeId),
      ),
    ]);
  }
}
