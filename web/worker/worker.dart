import 'dart:js_interop';

import 'package:web/web.dart' as web;

@JS()
external web.DedicatedWorkerGlobalScope get self;

void main() {
  self.onmessage = (web.MessageEvent e) {
    try {
      final data = e.data.dartify();
      if (data is Map) {
        final ktypes = <String>{};
        final vtypes = <String>{};
        for (var e in data.entries) {
          ktypes.add(e.key.runtimeType.toString());
          vtypes.add(e.value.runtimeType.toString());
        }
        self.postMessage(
            '${data.runtimeType} with keys: $ktypes and values: $vtypes'.toJS);
      } else if (data is List) {
        final itypes = <String>{};
        for (var e in data) {
          itypes.add(e.runtimeType.toString());
        }
        self.postMessage('${data.runtimeType} with items: $itypes'.toJS);
      } else {
        self.postMessage('${data.runtimeType}'.toJS);
      }
    } catch (ex) {
      self.postMessage('ERROR: $ex'.toJS);
    }
  }.toJS;

  self.postMessage('READY'.toJS);
}
