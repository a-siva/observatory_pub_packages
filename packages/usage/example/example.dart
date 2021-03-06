// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/**
 * A simple web app to hand-test the usage library.
 */
library usage_example;

import 'dart:html';

import 'package:usage/usage_html.dart';

Analytics _analytics;
String _lastUa;
int _count = 0;

void main() {
  querySelector('#foo').onClick.listen((_) => _handleFoo(getAnalytics()));
  querySelector('#bar').onClick.listen((_) => _handleBar(getAnalytics()));
  querySelector('#page').onClick.listen((_) => _changePage(getAnalytics()));
}

String _ua() => (querySelector('#ua') as InputElement).value.trim();

Analytics getAnalytics() {
  if (_analytics == null || _lastUa != _ua()) {
    _lastUa = _ua();
    _analytics = new AnalyticsHtml(_lastUa, 'Test app', '1.0');
    _analytics.optIn = true;
    _analytics.sendScreenView(window.location.pathname);
  }

  return _analytics;
}

void _handleFoo(Analytics analytics) {
  analytics.sendEvent('main', 'foo');
}

void _handleBar(Analytics analytics) {
  analytics.sendEvent('main', 'bar');
}

void _changePage(Analytics analytics) {
  window.history.pushState(null, 'new page', '${++_count}.html');
  analytics.sendScreenView(window.location.pathname);
}
