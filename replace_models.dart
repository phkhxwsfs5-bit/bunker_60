import 'dart:io';

void main() {
  var path = r'C:\Projeler\bunker_60\lib\models.dart';
  var text = File(path).readAsStringSync();
  
  var oldChoice = '''class EventChoice {
  final String buttonText;
  final Function() onSelect;
  final bool isEnabled;

  EventChoice({required this.buttonText, required this.onSelect, this.isEnabled = true});
});
}''';

  var newChoice = '''class EventChoice {
  final String buttonText;
  final Function() onSelect;
  final bool isEnabled;

  EventChoice({required this.buttonText, required this.onSelect, this.isEnabled = true});
}''';

  text = text.replaceAll('\r\n', '\n');
  oldChoice = oldChoice.replaceAll('\r\n', '\n');
  newChoice = newChoice.replaceAll('\r\n', '\n');

  text = text.replaceAll(oldChoice, newChoice);
  File(path).writeAsStringSync(text);
}
