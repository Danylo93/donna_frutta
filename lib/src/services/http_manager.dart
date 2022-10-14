import 'package:dio/dio.dart';

abstract class HttpMethods {
  static const String post = 'POST';
  static const String get = 'GET';
  static const String put = 'PUT';
  static const String patch = 'PATCH';
  static const String delete = 'DELETE';
}

class HttpManager {
  Future<Map> restRequest({
    required String url,
    required String method,
    Map? headers,
    Map? body,
  }) async {
    //Headers da requisicao

    final defaultHeaders = headers?.cast<String, String>() ?? {}
      ..addAll({
        'content-type': 'application/json',
        'accept': 'application/json',
        'X-Parse-Application-Id': 'iHSphVTpawXzpa2QmqAMz2gofddiXdhJb6WtxImu',
        'X-Parse-REST-API-Key': 'AYaeHzGIm7ygRsMt8a3ZZTPwtyyZoDVfknnT29l2',
      });

    Dio dio = Dio();

    try {
      Response response = await dio.request(
        url,
        options: Options(
          headers: defaultHeaders,
          method: method,
        ),
        data: body,
      );
      //Retorno do resultado do backend
      return response.data;
    } on DioError catch (error) {
      //Retorno do resultado do dio request
      return error.response?.data ?? {};
    } catch (error) {
      //Retorno de map vazio para erro generalizado
      return {};
    }
  }
}
