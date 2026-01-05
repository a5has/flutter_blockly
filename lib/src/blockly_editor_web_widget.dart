import 'package:flutter/material.dart';

import 'blockly_editor_web.dart';
import 'types/types.dart';

/// The Flutter Blockly widget visual programming editor
class BlocklyEditorWidget extends StatefulWidget {
  /// ## Example
  /// ```dart
  /// @override
  /// Widget build(BuildContext context) {
  ///   return Scaffold(
  ///     body: SafeArea(
  ///       child: BlocklyEditorWidget(
  ///         workspaceConfiguration: workspaceConfiguration,
  ///         initial: initial,
  ///         onInject: onInject,
  ///         onChange: onChange,
  ///         onDispose: onDispose,
  ///         onError: onError,
  ///       ),
  ///     ),
  ///   );
  /// }
  /// ```
  const BlocklyEditorWidget({
    super.key,
    this.workspaceConfiguration,
    this.initial,
    this.onError,
    this.onInject,
    this.onChange,
    this.onDispose,
    this.style,
    this.script,
    this.editor,
    this.packages,
    this.loadingIndicator,
  });

  /// [BlocklyOptions interface](https://developers.google.com/blockly/reference/js/blockly.blocklyoptions_interface)
  final BlocklyOptions? workspaceConfiguration;

  /// Blockly initial state (xml string or json)
  final dynamic initial;

  /// It is called on any error
  final Function? onError;

  /// It is called on inject editor
  final Function? onInject;

  /// It is called on change editor sate
  final Function? onChange;

  /// It is called on dispose editor
  final Function? onDispose;

  /// html render style
  final String? style;

  /// html render script
  final String? script;

  /// html render editor
  final String? editor;

  /// html render packages
  final String? packages;

  /// Widget to display while the editor is loading. Defaults to a centered CircularProgressIndicator.
  final Widget? loadingIndicator;

  @override
  State<BlocklyEditorWidget> createState() => _BlocklyEditorWidgetState();
}

class _BlocklyEditorWidgetState extends State<BlocklyEditorWidget> {
  late final BlocklyEditor editor;
  late final Future <void> _initEditor;

  @override
  void initState() {
    super.initState();

    /// Create new BlocklyEditor
    editor = BlocklyEditor(
      workspaceConfiguration: widget.workspaceConfiguration,
      initial: widget.initial,
      onError: widget.onError,
      onInject: widget.onInject,
      onChange: widget.onChange,
      onDispose: widget.onDispose,
      onDomReady: onDomReady,
    );

    editor.addJavaScriptChannel(
      'FlutterWebView',
      onMessageReceived: editor.onMessage,
    );
    _initEditor = editor.htmlRender(
      style: widget.style,
      script: widget.script,
      editor: widget.editor,
      packages: widget.packages,
    );
  }

  void onDomReady() {
    // For editor.init() we need to ensure that the widget has been fully initialized,
    // and the DOM finished building (div #blocklyEditor) and scripts loaded (JS `editor`).
    // JS side signals this by calling onDomReady callback.
    editor.init();
  }

  @override
  void dispose() {
    editor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initEditor,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return const HtmlElementView(viewType: 'blocklyEditor');
        } else {
          return widget.loadingIndicator ??
              const Center(
                child: CircularProgressIndicator(),
              );
        }
      }
    );
  }
}
