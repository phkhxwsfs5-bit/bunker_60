import 'dart:io';

void main() {
  var path = r'C:\Projeler\bunker_60\lib\bunker_screen.dart';
  var text = File(path).readAsStringSync();
  
  var oldBuildAction = '''  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 8, spreadRadius: 1)
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          ],
        ),
      ),
    );
  }''';

  var newBuildAction = '''  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback? onTap) {
    bool isEnabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: isEnabled ? color.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isEnabled ? color.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.3), width: 1.5),
          boxShadow: isEnabled ? [
            BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 8, spreadRadius: 1)
          ] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isEnabled ? color : Colors.grey, size: 20),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: isEnabled ? Colors.white : Colors.grey, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          ],
        ),
      ),
    );
  }''';

  // Normalize line endings to deal with CRLF/LF issues
  text = text.replaceAll('\r\n', '\n');
  oldBuildAction = oldBuildAction.replaceAll('\r\n', '\n');
  newBuildAction = newBuildAction.replaceAll('\r\n', '\n');

  text = text.replaceAll(oldBuildAction, newBuildAction);

  File(path).writeAsStringSync(text);
}
