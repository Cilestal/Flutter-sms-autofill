import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';

class PhoneFieldHint extends StatefulWidget {
  final bool autofocus;
  final FocusNode focusNode;
  final TextEditingController controller;
  final TextField child;

  const PhoneFieldHint({
    Key key,
    this.child,
    this.controller,
    this.autofocus = false,
    this.focusNode,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PhoneFieldHintState();
  }
}

class _PhoneFieldHintState extends State<PhoneFieldHint> {
  final SmsAutoFill _autoFill = SmsAutoFill();
  TextEditingController _controller;
  FocusNode _focusNode;
  bool _hintShown = false;

  @override
  void initState() {
    _controller = widget.controller ?? widget.child?.controller ?? TextEditingController(text: '');
    _focusNode = widget.focusNode ?? widget.child?.focusNode ?? FocusNode();
    _focusNode.addListener(() async {
      if (_focusNode.hasFocus && !_hintShown) {
        _hintShown = true;
        scheduleMicrotask(() {
          _askPhoneHint();
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ??
        TextField(
          autofocus: widget.autofocus,
          focusNode: _focusNode,
          decoration: InputDecoration(
            suffixIcon: Platform.isAndroid
                ? IconButton(
                    icon: Icon(Icons.phonelink_setup),
                    onPressed: () async {
                      _hintShown = true;
                      await _askPhoneHint();
                    },
                  )
                : null,
          ),
          controller: _controller,
          keyboardType: TextInputType.phone,
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _askPhoneHint() async {
    String hint = await _autoFill.hint;
    _controller.value = TextEditingValue(text: hint ?? '');
  }
}
