import 'package:quitanda_app/src/constants/endpoints.dart';
import 'package:quitanda_app/src/services/http_manager.dart';

class OrdersRepository {
  final _httpManager = HttpManager();

  Future getAllOrders({required String userId, required String token}) async {
    final result = await _httpManager.restRequest(
      url: Endpoints.getAllOrders,
      method: HttpMethods.post,
      body: {
        'user': userId,
      },
      headers: {
        'X-Parse-Session-Token': token,
      },
    );

    // if (result['result'] != null) {
    //   List<OrderModel> order = List<Map<String, dynamic>>.from(result['result'])
    //       .map(OrderModel.fromJson)
    //       .toList();
    // }else{

    // }
  }
}
