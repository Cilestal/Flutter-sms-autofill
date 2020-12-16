import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';

class PinFieldAutoFill extends StatefulWidget {
  final int codeLength;
  final bool autofocus;
  final TextEditingController controller;
  final String currentCode;
  final Function(String) onCodeSubmitted;
  final Function(String) onCodeChanged;
  final PinDecoration decoration;
  final FocusNode focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;

  const PinFieldAutoFill({
    Key key,
    this.keyboardType = const TextInputType.numberWithOptions(),
    this.textInputAction = TextInputAction.done,
    this.focusNode,
    this.controller,
    this.decoration = const UnderlineDecoration(
        colorBuilder: FixedColorBuilder(Colors.black), textStyle: TextStyle(color: Colors.black)),
    this.onCodeSubmitted,
    this.onCodeChanged,
    this.currentCode,
    this.autofocus = false,
    this.codeLength = 6,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PinFieldAutoFillState();
  }
}

class _PinFieldAutoFillState extends State<PinFieldAutoFill> with CodeAutoFill {
  TextEditingController controller;
  bool _shouldDisposeController;
  String code;

  @override
  Widget build(BuildContext context) {
    return PinInputTextField(
      pinLength: widget.codeLength,
      decoration: widget.decoration,
      focusNode: widget.focusNode,
      enableInteractiveSelection: true,
      autocorrect: false,
      textCapitalization: TextCapitalization.none,
      toolbarOptions: ToolbarOptions(paste: true),
      keyboardType: widget.keyboardType,
      autoFocus: widget.autofocus,
      controller: controller,
      textInputAction: widget.textInputAction,
      onSubmit: widget.onCodeSubmitted,
    );
  }

  @override
  void initState() {
    _shouldDisposeController = widget.controller == null;
    controller = widget.controller ?? TextEditingController(text: '');
    code = widget.currentCode;
    codeUpdated(code);
    controller.addListener(() {
      if (controller.text != code) {
        code = controller.text;
        if (widget.onCodeChanged != null) {
          widget.onCodeChanged(code);
        }
      }
    });
    listenForCode();
    super.initState();
  }

  @override
  void didUpdateWidget(PinFieldAutoFill oldWidget) {
    if (widget.controller != null && widget.controller != controller) {
      controller.dispose();
      controller = widget.controller;
    }

    if (widget.currentCode != oldWidget.currentCode || widget.currentCode != code) {
      code = widget.currentCode;
      codeUpdated(code);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void codeUpdated(String code) {
    if (controller.text != code) {
      controller.value = TextEditingValue(text: code ?? '');
      if (widget.onCodeChanged != null) {
        widget.onCodeChanged(code ?? '');
      }
    }
  }

  @override
  void dispose() {
    if (_shouldDisposeController) {
      controller.dispose();
    }
    unregisterListener();
    super.dispose();
  }
}
