import 'dart:js_interop';

import 'package:web/web.dart' as web;

sealed class Logger {
  static String _esc(String message) => message
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');

  static void trace(String message) {
    final output = web.document.querySelector('#output') as web.HTMLDivElement;
    output.innerHTML =
        '${output.innerHTML}<span class="log trace">[TRACE] ${_esc(message)}</span><br/>'
            .toJS;
  }

  static void info(String message) {
    final output = web.document.querySelector('#output') as web.HTMLDivElement;
    if (message.trim().isEmpty) {
      output.innerHTML = '${output.innerHTML}<br/>'.toJS;
    } else {
      output.innerHTML =
          '${output.innerHTML}<span class="log info">[INFO] ${_esc(message)}</span><br/>'
              .toJS;
    }
  }

  static void error(String message) {
    final output = web.document.querySelector('#output') as web.HTMLDivElement;
    output.innerHTML =
        '${output.innerHTML}<span class="log error">[ERROR] ${_esc(message)}</span><br/>'
            .toJS;
  }
}
