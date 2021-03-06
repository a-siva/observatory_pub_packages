// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn("browser")
library usage.web_test;

import 'dart:async';

import 'package:test/test.dart';
import 'package:usage/src/usage_impl_html.dart';

import 'hit_types_test.dart' as hit_types_test;
import 'usage_impl_test.dart' as usage_impl_test;
import 'usage_test.dart' as usage_test;
import 'uuid_test.dart' as uuid_test;

void main() {
  // Define the tests.
  hit_types_test.defineTests();
  usage_test.defineTests();
  usage_impl_test.defineTests();
  uuid_test.defineTests();

  // Define some web specfic tests.
  defineWebTests();
}

void defineWebTests() {
  group('HtmlPostHandler', () {
    test('sendPost', () {
      MockRequestor client = new MockRequestor();
      HtmlPostHandler postHandler = new HtmlPostHandler(
          mockRequestor: client.request);
      Map<String, dynamic> args = {'utv': 'varName', 'utt': 123};
      return postHandler.sendPost('http://www.google.com', args).then((_) {
        expect(client.sendCount, 1);
      });
    });
  });

  group('HtmlPersistentProperties', () {
    test('add', () {
      HtmlPersistentProperties props = new HtmlPersistentProperties('foo_props');
      props['foo'] = 'bar';
      expect(props['foo'], 'bar');
    });

    test('remove', () {
      HtmlPersistentProperties props = new HtmlPersistentProperties('foo_props');
      props['foo'] = 'bar';
      expect(props['foo'], 'bar');
      props['foo'] = null;
      expect(props['foo'], null);
    });
  });
}

class MockRequestor {
  int sendCount = 0;

  Future request(String url, {String method, String sendData}) {
    expect(url, isNotEmpty);
    expect(method, isNotEmpty);
    expect(sendData, isNotEmpty);

    sendCount++;
    return new Future.value();
  }
}
