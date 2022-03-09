import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioService {
  DioService({required this.baseUrl});

  final String baseUrl;

  static final CancelToken _cancelToken = CancelToken();
  final int _timeOut = 10000;

  Dio _makeBaseDio() {
    return Dio()
      ..options.baseUrl = baseUrl
      ..options.connectTimeout = _timeOut
      ..interceptors.addAll([
        PrettyDioLogger(
          request: true,
          requestHeader: true,
          requestBody: true,
          error: true,
          responseHeader: true,
          responseBody: true,
        ),
      ]);
  }

  dynamic _onDioError(DioError e, ErrorInterceptorHandler h) {
    if (e.error != null && e.error is Error) {
      // send error to somewhere
    }

    // _dioServiceErrorHandler.dioError = e;

    if (e.response != null) return h.resolve(e.response!);

    return h.next(e);
  }

  Dio getDio() {
    final Dio baseDio = _makeBaseDio();

    // add apitoken if any

    return baseDio
      ..options.headers.addAll(<String, dynamic>{
        HttpHeaders.contentTypeHeader: 'application/json',
        // HttpHeaders.authorizationHeader: 'Bearer $apiToken'
      })
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (
            RequestOptions option,
            RequestInterceptorHandler handler,
          ) async {
            option.cancelToken = _cancelToken;

            return handler.next(option);
          },
          onError: _onDioError,
        ),
      );
  }

  Dio? getDioJwt() {
    final Dio baseDio = _makeBaseDio();

    return baseDio
      ..options.headers.addAll(<String, dynamic>{
        HttpHeaders.contentTypeHeader: 'application/json',
      })
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (
            RequestOptions option,
            RequestInterceptorHandler handler,
          ) async {
            option.cancelToken =
                _cancelToken; //Assign _cancelToken for cancelling request later

            // add JWT functionality if any

            // if (jwtToken != null) {
            //   if (!option.headers
            //       .containsKey(HttpHeaders.authorizationHeader)) {
            //     option.headers[HttpHeaders.authorizationHeader] =
            //         'Bearer $jwtToken';
            //   }
            // } else {
            //   option.headers.remove(HttpHeaders.authorizationHeader);
            //   _cancelToken.cancel(
            //     'LOGGED_OUT',
            //   ); //Cancel All Request With _cancelToken

            //   _cancelToken = CancelToken();
            // }

            return handler.next(option);
          },
          onError: _onDioError,
        ),
      );
  }
}
