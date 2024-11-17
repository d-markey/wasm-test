## Sample app showcasing type discrepancies between JS and WASM

Compile the app with `tool\build.bat`:

```bash
cd ./web
dart compile js ./main.dart -o ./main.dart.js 
dart compile js ./worker/worker.dart -o ./worker/worker.dart.js 
dart compile wasm ./worker/worker.dart -o ./worker/worker.dart.wasm 
```

Serve the app with `tool\serve.bat`:

```bash
cd ./web
dart pub global run dhttpd --port=8181
```

Open up a browser to http://localhost:8181/ and see the results:

```
[TRACE] Loading JS Web worker...
[TRACE] JS Web worker is ready, running tests...
[INFO] Sent String "This is a test", worker received String
[INFO] Sent int "5", worker received int
[INFO] Sent double "3.141592653589793", worker received double
[INFO] Sent JSArray<String> "[Posting, a, list]", worker received JSArray<dynamic> with items: {String}
[INFO] Sent JsLinkedHashMap<int, double> "{1: 125}", worker received JsLinkedHashMap<Object?, Object?> with keys: {String} and values: {int}
[INFO] Sent JsLinkedHashMap<bool, bool> "{true: false, false: true}", worker received JsLinkedHashMap<Object?, Object?> with keys: {String} and values: {bool}
[TRACE] Terminating JS Web worker...

[TRACE] Loading WASM Web worker...
[TRACE] WASM Web worker is ready, running tests...
[INFO] Sent String "This is a test", worker received JSStringImpl
[INFO] Sent int "5", worker received double
[INFO] Sent double "3.141592653589793", worker received double
[INFO] Sent JSArray<String> "[Posting, a, list]", worker received List<Object?> with items: {JSStringImpl}
[INFO] Sent JsLinkedHashMap<int, double> "{1: 125}", worker received _WasmDefaultMap<Object?, Object?> with keys: {JSStringImpl} and values: {double}
[INFO] Sent JsLinkedHashMap<bool, bool> "{true: false, false: true}", worker received _WasmDefaultMap<Object?, Object?> with keys: {JSStringImpl} and values: {bool}
[TRACE] Terminating WASM Web worker...

[INFO] Done
```

JavaScript and Web Assembly do not handle `int` and `double` the same way, and this is somewhat documented.

Maps and lists loose their strong types on the way, which is also expected. However, it is surprising that `<int, double>{}` and `<bool, bool>{}` are received as `<Object?, Object?>{}` (OK) with `double` or `bool` values (OK also), yet `String` or `JSString` keys.

