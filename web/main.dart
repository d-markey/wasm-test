import 'dart:async';
import 'dart:math' as math;

import 'package:web/web.dart' as web;

import 'logger.dart';
import 'worker_management.dart';

void main() async {
  web.Worker? worker;

  try {
    Logger.trace('Loading JS Web worker...');
    worker = await startJsWorker();
    Logger.trace('JS Web worker is ready, running tests...');
    await runTests(worker);
  } catch (ex) {
    Logger.error('CAUGHT EXCEPTION: $ex');
  } finally {
    Logger.trace('Terminating JS Web worker...');
    worker?.terminate();
    worker = null;
  }

  Logger.info('');

  try {
    Logger.trace('Loading WASM Web worker...');
    worker = await startWasmWorker();
    Logger.trace('WASM Web worker is ready, running tests...');
    await runTests(worker);
  } catch (ex) {
    Logger.error('CAUGHT EXCEPTION: $ex');
  } finally {
    Logger.trace('Terminating WASM Web worker...');
    worker?.terminate();
    worker = null;
  }

  Logger.info('');
  Logger.info('Done');
}

Future<void> runTests(web.Worker worker) async {
  Object msg = 'This is a test';
  dynamic res = await callWorker(worker, msg);
  Logger.info('Sent ${msg.runtimeType} "$msg", worker received $res');

  msg = 5;
  res = await callWorker(worker, msg);
  Logger.info('Sent ${msg.runtimeType} "$msg", worker received $res');

  msg = math.pi;
  res = await callWorker(worker, msg);
  Logger.info('Sent ${msg.runtimeType} "$msg", worker received $res');

  msg = ['Posting', 'a', 'list'];
  res = await callWorker(worker, msg);
  Logger.info('Sent ${msg.runtimeType} "$msg", worker received $res');

  msg = <int, double>{1: 125};
  res = await callWorker(worker, msg);
  Logger.info('Sent ${msg.runtimeType} "$msg", worker received $res');

  msg = <bool, bool>{true: false, false: true};
  res = await callWorker(worker, msg);
  Logger.info('Sent ${msg.runtimeType} "$msg", worker received $res');
}
