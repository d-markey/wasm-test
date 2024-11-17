import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<dynamic> callWorker(web.Worker worker, Object message) async {
  final completer = Completer();

  void $success(dynamic data) {
    if (!completer.isCompleted) completer.complete(data);
  }

  void $error(dynamic data) {
    if (!completer.isCompleted) completer.complete(data);
  }

  final timeout = Timer.periodic(const Duration(minutes: 3), (t) {
    t.cancel();
    $error(TimeoutException('ERROR: timeout for $message'));
  });

  worker.onmessage = (web.MessageEvent e) {
    worker.onmessage = null;
    if (timeout.isActive) {
      timeout.cancel();
      final data = e.data.dartify();
      if (data is String && data.startsWith('ERROR')) {
        $error(data);
      } else {
        $success(data);
      }
    }
  }.toJS;

  worker.postMessage(message.jsify());

  return completer.future;
}

Future<web.Worker> startJsWorker() {
  return startWorker('/worker/worker.dart.js');
}

Future<web.Worker> startWasmWorker() {
  final workerUrl = '/worker/worker.dart.wasm';
  final blob = web.Blob(
    [wasmLoaderScript(workerUrl).toJS].toJS,
    web.BlobPropertyBag(type: 'application/javascript'),
  );
  final url = web.URL.createObjectURL(blob);
  return startWorker(url).whenComplete(() {
    web.URL.revokeObjectURL(url);
  });
}

Future<web.Worker> startWorker(String url) async {
  final worker = web.Worker(url.toJS);

  final ready = Completer();
  worker.onmessage = (web.MessageEvent e) {
    if (e.data.dartify() == 'READY') {
      ready.complete();
    } else {
      ready.completeError('Unexpected message');
    }
  }.toJS;

  await ready.future;
  worker.onmessage = null;

  return worker;
}

String wasmLoaderScript(String url) => '''(async function() {
  const workerUri = new URL("${url.replaceAll('"', '\\"')}", self.location.origin).href;
  try {
    let dart2wasm_runtime; let moduleInstance;
    const runtimeUri = workerUri.replaceAll('.unopt', '').replaceAll('.wasm', '.mjs');
    try {
      const dartModule = WebAssembly.compileStreaming(fetch(workerUri));
      dart2wasm_runtime = await import(runtimeUri);
      moduleInstance = await dart2wasm_runtime.instantiate(dartModule, {});
    } catch (exception) {
      console.error(`Failed to fetch and instantiate wasm module \${workerUri}: \${exception}`);
      console.error('See https://dart.dev/web/wasm for more information.');
      throw new Error(exception.message ?? 'Unknown error when instantiating worker module');
    }
    try {
      await dart2wasm_runtime.invoke(moduleInstance);
      console.log(`Succesfully loaded and invoked \${workerUri}`);
    } catch (exception) {
      console.error(`Exception while invoking wasm module \${workerUri}: \${exception}`);
      throw new Error(exception.message ?? 'Unknown error when invoking worker module');
    }
  } catch (ex) {
    throw `WASM INITIALIZATION ERROR: \${ex}`;
  }
})()''';
