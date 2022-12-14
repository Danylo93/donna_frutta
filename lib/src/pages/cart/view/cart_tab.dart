import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quitanda_app/src/config/custom_colors.dart';
import 'package:quitanda_app/src/constants/storage_keys.dart';
import 'package:quitanda_app/src/pages/auth/controller/auth_controller.dart';
import 'package:quitanda_app/src/pages/cart/controller/cart_controller.dart';
import 'package:quitanda_app/src/pages/cart/view/components/cart_tile.dart';
import 'package:quitanda_app/src/services/utils_services.dart';
import 'package:dio/dio.dart';


class CartTab extends StatefulWidget {
  const CartTab({Key? key}) : super(key: key);

  @override
  State<CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<CartTab> {
  final UtilsServices utilsServices = UtilsServices();
  final cartController = Get.find<CartController>();
   final authController = Get.find<AuthController>();

  Future <void> checkout()  async {
 try{
  final response = await  Dio().post('https://parseapi.back4app.com/parse/functions/checkout', 
    options: 
    Options(
      headers: {
        'X-Parse-Application-Id': 'iHSphVTpawXzpa2QmqAMz2gofddiXdhJb6WtxImu',
        'X-Parse-REST-API-Key': 'AYaeHzGIm7ygRsMt8a3ZZTPwtyyZoDVfknnT29l2',
        'X-Parse-Session-Token': authController.user.token!,
        'Content-Type': 'application/json'
    },
    
    ),
    data: {
      'total' : cartController.cartTotalPrice()
    }
    );
    print(response.data);
 } on DioError catch(e){
  print(e.response);
 }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrinho'),
      ),
      body: Column(
        children: [
          // Lista de itens do carrinho
          Expanded(
            child: GetBuilder<CartController>(
              builder: (controller) {
                if (controller.cartItems.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.remove_shopping_cart,
                        size: 40,
                        color: CustomColors.customSwatchColor,
                      ),
                      const Text('N??o h?? itens no carrinho'),
                    ],
                  );
                }

                return ListView.builder(
                  itemCount: controller.cartItems.length,
                  itemBuilder: (_, index) {
                    return CartTile(
                      cartItem: controller.cartItems[index],
                    );
                  },
                );
              },
            ),
          ),

          // Total e bot??o de concluir o pedido
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 3,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total geral',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      GetBuilder<CartController>(
                        builder: (controller) {
                          return Text(
                            utilsServices
                                .priceToCurrency(controller.cartTotalPrice()),
                            style: TextStyle(
                              fontSize: 23,
                              color: CustomColors.customSwatchColor,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: GetBuilder<CartController>(
                    builder: (controller) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: CustomColors.customSwatchColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: (controller.isCheckoutLoading ||
                                controller.cartItems.isEmpty)
                            ? null
                            : () async {
                                bool? result = await showOrderConfirmation();

                                if (result ?? false) {
                                  cartController.checkoutCart();
                                } else {
                                  utilsServices.showToast(
                                    message: 'Pedido n??o confirmado',
                                  );
                                }
                              },
                        child: controller.isCheckoutLoading
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Concluir pedido',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> showOrderConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Confirma????o'),
          content: const Text('Deseja realmente concluir o pedido?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('N??o'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                checkout();
                Navigator.of(context).pop(true);
              },
              child: const Text('Sim'),
            ),
          ],
        );
      },
    );
  }
}