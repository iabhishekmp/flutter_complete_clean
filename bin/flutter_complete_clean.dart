import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cli_util/cli_logging.dart';

late final Logger logger;

Future<void> main(List<String> arguments) async {
  final isVerbose = arguments.contains('-v');
  logger = isVerbose ? Logger.verbose() : Logger.standard();

  final currentDir = Directory.current;
  logger.stdout("currentDir: $currentDir");

  final beforeSize = await currentDir.getSize;

  final files = currentDir.getAllPubspec;

  //? cleaning all the flutter projects
  for (final file in files) {
    final dir = file.parent;

    final process = await dir.flutterClean();

    var progress = logger.progress(dir.path);
    await process.exitCode;
    progress.finish(showTiming: true);
  }

  //? log sizes
  final afterSize = await currentDir.getSize;
  logger.stdout('BeforeSize: $beforeSize MB, AfterSize: $afterSize MB');
  logger.stdout('Saved: ${beforeSize - afterSize} MB');
}

extension DirectoryExtension on Directory {
  Iterable<File> get getAllPubspec =>
      listSync(recursive: true, followLinks: false)
          .whereType<File>()
          .where((e) => e.path.endsWith('pubspec.yaml'));

  Future<Process> flutterClean() async {
    final process = await Process.start(
      "flutter",
      ["clean"],
      workingDirectory: path,
      runInShell: true,
    );
    process.stdout.transform(utf8.decoder).forEach(logger.trace);
    return process;
  }

  /// in MB
  Future<double> get getSize async {
    int totalSize = 0;
    listSync(recursive: true, followLinks: false)
        .forEach((FileSystemEntity entity) {
      if (entity is File) {
        totalSize += entity.lengthSync();
      }
    });
    return (totalSize / 1000000);
  }
}
