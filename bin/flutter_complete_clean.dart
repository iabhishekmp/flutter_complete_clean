import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cli_util/cli_logging.dart';

Future<void> main(List<String> arguments) async {
  //? logger
  final isVerbose = arguments.contains('-v');
  final logger = isVerbose ? Logger.verbose() : Logger.standard();

  //? current directory
  final currentDir = Directory.current;
  logger.stdout("currentDir: $currentDir");

  //? getting all the flutter projects
  final files = currentDir
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((e) => e.path.endsWith('pubspec.yaml'));

  //? cleaning all the flutter projects
  for (final file in files) {
    // log the directory
    final dir = file.parent;

    // starting flutter clean
    final process = await Process.start(
      "flutter",
      ["clean"],
      workingDirectory: dir.path,
      runInShell: true,
    );
    process.stdout.transform(utf8.decoder).forEach(logger.trace);

    var progress = logger.progress(dir.path);
    await process.exitCode;
    progress.finish(showTiming: true);
  }

  logger.stdout('Done');
}
