PUSHD "%~dp0..\web"

CALL dart compile js .\main.dart -o .\main.dart.js 
CALL dart compile js .\worker\worker.dart -o .\worker\worker.dart.js 
CALL dart compile wasm .\worker\worker.dart -o .\worker\worker.dart.wasm 

POPD
