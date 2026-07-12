import 'package:flutter/material.dart';

/// True while [context]'s route is still the one on top of the stack.
///
/// A rapid double-tap on a card/button can fire two navigation callbacks
/// before the first push/pop has rebuilt anything. Checking this before
/// navigating stops the second tap from pushing (or popping) a second
/// time — no separate debounce timer or disabled-state needed.
bool isRouteCurrent(BuildContext context) => ModalRoute.of(context)?.isCurrent ?? true;
