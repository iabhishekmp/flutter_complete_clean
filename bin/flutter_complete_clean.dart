import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> arguments) async {
  final currentDir = Directory.current;
  print("currentDir: $currentDir");
  final files = currentDir
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((e) => e.path.endsWith('pubspec.yaml'));

  // add all the process to the list
  for (final file in files) {
    final dir = file.parent;
    print(dir.path);
    final process = await Process.start(
      "flutter",
      ["clean"],
      workingDirectory: dir.path,
      runInShell: true,
    );
    process.stdout.transform(utf8.decoder).forEach(print);
    await process.exitCode;
  }

  print('Done');
}
