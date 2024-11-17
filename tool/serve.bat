PUSHD "%~dp0..\web"

CALL dart pub global run dhttpd --port=8181

POPD