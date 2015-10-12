// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library usage.usage_impl_io_test;

import 'dart:async';
import 'dart:io';

import 'package:unittest/unittest.dart';
import 'package:usage/src/usage_impl_io.dart';

void defineTests() {
  group('IOPostHandler', () {
    test('sendPost', () {
      var httpClient = new MockHttpClient();
      IOPostHandler postHandler = new IOPostHandler(mockClient: httpClient);
      Map args = {'utv': 'varName', 'utt': 123};
      return postHandler.sendPost('http://www.google.com', args).then((_) {
        expect(httpClient.sendCount, 1);
      });
    });
  });

  group('IOPersistentProperties', () {
    test('add', () {
      IOPersistentProperties props = new IOPersistentProperties('foo_props');
      props['foo'] = 'bar';
      expect(props['foo'], 'bar');
    });

    test('remove', () {
      IOPersistentProperties props = new IOPersistentProperties('foo_props');
      props['foo'] = 'bar';
      expect(props['foo'], 'bar');
      props['foo'] = null;
      expect(props['foo'], null);
    });
  });
}

class MockHttpClient implements HttpClient {
  String userAgent;
  int sendCount = 0;
  int writeCount = 0;
  bool closed = false;
  Future<HttpClientRequest> postUrl(Uri url) {
    return new Future.value(new MockHttpClientRequest(this));
  }
  noSuchMethod(Invocation invocation) { }
}

class MockHttpClientRequest implements HttpClientRequest {
  final MockHttpClient client;
  MockHttpClientRequest(this.client);
  void write(Object obj) {
    client.writeCount++;
  }
  Future<HttpClientResponse> close() {
    client.closed = true;
    return new Future.value(new MockHttpClientResponse(client));
  }
  noSuchMethod(Invocation invocation) { }
}

class MockHttpClientResponse implements HttpClientResponse {
  final MockHttpClient client;
  MockHttpClientResponse(this.client);
  Future drain([var futureValue]) {
    client.sendCount++;
    return new Future.value();
  }
  noSuchMethod(Invocation invocation) { }
}
