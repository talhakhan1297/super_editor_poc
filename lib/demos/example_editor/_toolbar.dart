import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';
import 'package:super_editor_alignable_list_item/super_editor_alignable_list_item.dart';

/// A mobile document editing toolbar, which is displayed in the application
/// [Overlay], and is mounted just above the software keyboard.
///
/// Despite displaying the toolbar in the application [Overlay], [EditorToolbar]
/// also (optionally) inserts some blank space into the current subtree, which takes up
/// the same amount of height as the toolbar that appears in the [Overlay].
///
/// Provides document editing capabilities, like converting paragraphs to blockquotes
/// and list items, and inserting horizontal rules.
class EditorToolbar extends StatefulWidget {
  const EditorToolbar({
    Key? key,
    required this.editor,
    required this.document,
    required this.composer,
    required this.commonOps,
  }) : super(key: key);

  final Editor editor;
  final Document document;
  final DocumentComposer composer;
  final CommonEditorOperations commonOps;

  @override
  State<EditorToolbar> createState() => _EditorToolbarState();
}

class _EditorToolbarState extends State<EditorToolbar> with WidgetsBindingObserver {
  late EditorToolbarOperations _toolbarOps;

  @override
  void initState() {
    super.initState();

    _toolbarOps = EditorToolbarOperations(
      editor: widget.editor,
      document: widget.document,
      composer: widget.composer,
      commonOps: widget.commonOps,
    );
  }

  @override
  void didUpdateWidget(EditorToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);

    _toolbarOps = EditorToolbarOperations(
      editor: widget.editor,
      document: widget.document,
      composer: widget.composer,
      commonOps: widget.commonOps,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selection = widget.composer.selection;

    return SizedBox(
      height: 48,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ListenableBuilder(
            listenable: widget.composer,
            builder: (context, _) {
              final selectedNode = selection == null ? null : widget.document.getNodeById(selection.extent.nodeId);
              final isSingleNodeSelected = selection == null ? false : selection.extent.nodeId == selection.base.nodeId;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: selectedNode is TextNode ? _toolbarOps.toggleBold : null,
                    icon: const Icon(Icons.format_bold),
                    color: _toolbarOps.isBoldActive ? Theme.of(context).primaryColor : null,
                  ),
                  IconButton(
                    onPressed: selectedNode is TextNode ? _toolbarOps.toggleItalics : null,
                    icon: const Icon(Icons.format_italic),
                    color: _toolbarOps.isItalicsActive ? Theme.of(context).primaryColor : null,
                  ),
                  IconButton(
                    onPressed: selectedNode is TextNode ? _toolbarOps.toggleUnderline : null,
                    icon: const Icon(Icons.format_underline),
                    color: _toolbarOps.isUnderlineActive ? Theme.of(context).primaryColor : null,
                  ),
                  IconButton(
                    onPressed: selectedNode is TextNode ? _toolbarOps.toggleStrikethrough : null,
                    icon: const Icon(Icons.strikethrough_s),
                    color: _toolbarOps.isStrikethroughActive ? Theme.of(context).primaryColor : null,
                  ),
                  IconButton(
                    onPressed: isSingleNodeSelected &&
                            ((selectedNode is ParagraphNode && selectedNode.hasMetadataValue('blockType')) ||
                                (selectedNode is TextNode && selectedNode is! ParagraphNode))
                        ? _toolbarOps.convertToParagraph
                        : null,
                    icon: const Icon(Icons.wrap_text),
                  ),
                  IconButton(
                    onPressed: isSingleNodeSelected &&
                            (selectedNode is TextNode && selectedNode is! ListItemNode ||
                                (selectedNode is ListItemNode && selectedNode.type != ListItemType.ordered))
                        ? _toolbarOps.convertToOrderedListItem
                        : null,
                    icon: const Icon(Icons.looks_one_rounded),
                  ),
                  IconButton(
                    onPressed: isSingleNodeSelected &&
                            (selectedNode is TextNode && selectedNode is! ListItemNode ||
                                (selectedNode is ListItemNode && selectedNode.type != ListItemType.unordered))
                        ? _toolbarOps.convertToUnorderedListItem
                        : null,
                    icon: const Icon(Icons.list),
                  ),
                  IconButton(
                    onPressed: selectedNode is TextNode
                        ? () {
                            widget.editor.execute([
                              if (selectedNode is ParagraphNode)
                                ChangeParagraphAlignmentRequest(
                                  nodeId: widget.composer.selection!.extent.nodeId,
                                  alignment: TextAlign.left,
                                )
                              else if (selectedNode is ListItemNode)
                                ChangeListItemAlignmentRequest(
                                  nodeId: widget.composer.selection!.extent.nodeId,
                                  alignment: TextAlign.left,
                                ),
                            ]);
                          }
                        : null,
                    icon: const Icon(Icons.align_horizontal_left),
                  ),
                  IconButton(
                    onPressed: selectedNode is TextNode
                        ? () {
                            widget.editor.execute([
                              if (selectedNode is ParagraphNode)
                                ChangeParagraphAlignmentRequest(
                                  nodeId: widget.composer.selection!.extent.nodeId,
                                  alignment: TextAlign.right,
                                )
                              else if (selectedNode is ListItemNode)
                                ChangeListItemAlignmentRequest(
                                  nodeId: widget.composer.selection!.extent.nodeId,
                                  alignment: TextAlign.right,
                                ),
                            ]);
                          }
                        : null,
                    icon: const Icon(Icons.align_horizontal_right),
                  ),
                  IconButton(
                    onPressed: selectedNode is TextNode
                        ? () {
                            widget.editor.execute([
                              if (selectedNode is ParagraphNode)
                                ChangeParagraphAlignmentRequest(
                                  nodeId: widget.composer.selection!.extent.nodeId,
                                  alignment: TextAlign.center,
                                )
                              else if (selectedNode is ListItemNode)
                                ChangeListItemAlignmentRequest(
                                  nodeId: widget.composer.selection!.extent.nodeId,
                                  alignment: TextAlign.center,
                                ),
                            ]);
                          }
                        : null,
                    icon: const Icon(Icons.align_horizontal_center),
                  ),
                ],
              );
            }),
      ),
    );
  }
}

@visibleForTesting
class EditorToolbarOperations {
  EditorToolbarOperations({
    required this.editor,
    required this.document,
    required this.composer,
    required this.commonOps,
  });

  final Editor editor;
  final Document document;
  final DocumentComposer composer;
  final CommonEditorOperations commonOps;

  bool get isBoldActive => _doesSelectionHaveAttributions({boldAttribution});
  void toggleBold() => _toggleAttributions({boldAttribution});

  bool get isItalicsActive => _doesSelectionHaveAttributions({italicsAttribution});
  void toggleItalics() => _toggleAttributions({italicsAttribution});

  bool get isUnderlineActive => _doesSelectionHaveAttributions({underlineAttribution});
  void toggleUnderline() => _toggleAttributions({underlineAttribution});

  bool get isStrikethroughActive => _doesSelectionHaveAttributions({strikethroughAttribution});
  void toggleStrikethrough() => _toggleAttributions({strikethroughAttribution});

  bool _doesSelectionHaveAttributions(Set<Attribution> attributions) {
    final selection = composer.selection;
    if (selection == null) {
      return false;
    }

    if (selection.isCollapsed) {
      return composer.preferences.currentAttributions.containsAll(attributions);
    }

    return document.doesSelectedTextContainAttributions(selection, attributions);
  }

  void _toggleAttributions(Set<Attribution> attributions) {
    final selection = composer.selection;
    if (selection == null) {
      return;
    }

    selection.isCollapsed
        ? commonOps.toggleComposerAttributions(attributions)
        : commonOps.toggleAttributionsOnSelection(attributions);
  }

  void convertToParagraph() {
    commonOps.convertToParagraph();
  }

  void convertToOrderedListItem() {
    final selectedNode = document.getNodeById(composer.selection!.extent.nodeId)! as TextNode;

    commonOps.convertToListItem(ListItemType.ordered, selectedNode.text);
  }

  void convertToUnorderedListItem() {
    final selectedNode = document.getNodeById(composer.selection!.extent.nodeId)! as TextNode;

    commonOps.convertToListItem(ListItemType.unordered, selectedNode.text);
  }

  void closeKeyboard() {
    editor.execute([
      const ChangeSelectionRequest(
        null,
        SelectionChangeType.clearSelection,
        SelectionReason.userInteraction,
      ),
    ]);
  }
}
