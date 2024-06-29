import 'dart:convert';

import 'package:example/demos/example_editor/_toolbar.dart';
import 'package:example/demos/infrastructure/delta_ops.dart';
import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';
import 'package:super_editor_alignable_list_item/super_editor_alignable_list_item.dart';
import 'package:super_editor_quill/super_editor_quill.dart';

/// Example of a rich text editor.
///
/// This editor will expand in functionality as package
/// capabilities expand.
class ExampleEditor extends StatefulWidget {
  @override
  State<ExampleEditor> createState() => _ExampleEditorState();
}

class _ExampleEditorState extends State<ExampleEditor> {
  final GlobalKey _docLayoutKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  late MutableDocument _doc;
  final _docChangeSignal = SignalNotifier();
  late MutableDocumentComposer _composer;
  late Editor _docEditor;
  late CommonEditorOperations _docOps;

  late FocusNode _editorFocusNode;

  String delta = '';

  @override
  void initState() {
    super.initState();
    _composer = MutableDocumentComposer();

    _editorFocusNode = FocusNode();

    _doc = parseQuillDeltaOps(deltaOps)..addListener(_onDocumentChange);

    _docEditor = Editor(
      editables: {Editor.documentKey: _doc, Editor.composerKey: _composer},
      requestHandlers: [
        ...defaultRequestHandlers,
        (request) => request is ChangeListItemAlignmentRequest
            ? ChangeListItemAlignmentCommand(
                nodeId: request.nodeId,
                alignment: request.alignment,
              )
            : null,
      ],
      reactionPipeline: List.from(defaultEditorReactions),
    );

    _docOps = CommonEditorOperations(
      editor: _docEditor,
      document: _doc,
      composer: _composer,
      documentLayoutResolver: () => _docLayoutKey.currentState as DocumentLayout,
    );
    _renderDelta();
  }

  @override
  void dispose() {
    _editorFocusNode.dispose();
    _composer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onDocumentChange(_) {
    _renderDelta();
    _docChangeSignal.notifyListeners();
  }

  void _renderDelta() {
    var encoder = new JsonEncoder.withIndent("  ");
    encoder.convert(_doc.toQuillDeltas().toJson());
    setState(() {
      delta = encoder.convert(_doc.toQuillDeltas().toJson()).toString();
    });
  }

  String inputDelta = '[{"insert":"\n"}]';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: ListView(
        children: [
          const SizedBox(height: 56),
          Text("Delta Input 👇"),
          Container(
            color: Colors.grey[200],
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              maxLines: 4,
              onChanged: (value) {
                inputDelta = value;
              },
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _composer = MutableDocumentComposer();

                _editorFocusNode = FocusNode();

                _doc = parseQuillDeltaOps(jsonDecode(inputDelta.replaceAll(" ", "")))..addListener(_onDocumentChange);

                _docEditor = Editor(
                  editables: {Editor.documentKey: _doc, Editor.composerKey: _composer},
                  requestHandlers: [
                    ...defaultRequestHandlers,
                    (request) => request is ChangeListItemAlignmentRequest
                        ? ChangeListItemAlignmentCommand(
                            nodeId: request.nodeId,
                            alignment: request.alignment,
                          )
                        : null,
                  ],
                  reactionPipeline: List.from(defaultEditorReactions),
                );

                _docOps = CommonEditorOperations(
                  editor: _docEditor,
                  document: _doc,
                  composer: _composer,
                  documentLayoutResolver: () => _docLayoutKey.currentState as DocumentLayout,
                );
                _renderDelta();
              });
            },
            child: Text('Fill super editor with aboue delta'),
          ),
          Text("Super Editor View 👇"),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24),
            width: double.infinity,
            // height: 200,
            decoration: BoxDecoration(border: Border.all()),
            child: SuperEditor(
              editor: _docEditor,
              document: _doc,
              composer: _composer,
              focusNode: _editorFocusNode,
              documentLayoutKey: _docLayoutKey,
              scrollController: _scrollController,
              componentBuilders: <ComponentBuilder>[
                ParagraphComponentBuilder(),
                AlignableListItemComponentBuilder(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // _buildMountedToolbar(),
          Center(
            child: MultiListenableBuilder(
                listenables: <Listenable>{
                  _docChangeSignal,
                  _composer.selectionNotifier,
                },
                builder: (_) {
                  return EditorToolbar(
                    editor: _docEditor,
                    document: _doc,
                    composer: _composer,
                    commonOps: _docOps,
                  );
                }),
          ),
          const SizedBox(height: 24),
          Text("Super Editor to Delta 👇"),
          const SizedBox(height: 16),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 48),
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(border: Border.all()),
            child: SingleChildScrollView(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SelectableText((delta)),
            )),
          ),
          const SizedBox(height: 56),
        ],
      ),
    );
  }

  // Widget _buildMountedToolbar() {
  //   return MultiListenableBuilder(
  //     listenables: <Listenable>{
  //       _docChangeSignal,
  //       _composer.selectionNotifier,
  //     },
  //     builder: (_) {
  //       final selection = _composer.selection;

  //       if (selection == null) {
  //         return const SizedBox();
  //       }

  //       return KeyboardEditingToolbar(
  //         editor: _docEditor,
  //         document: _doc,
  //         composer: _composer,
  //         commonOps: _docOps,
  //       );
  //     },
  //   );
  // }
}
