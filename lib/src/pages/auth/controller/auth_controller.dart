import 'package:get/get.dart';
import 'package:quitanda_app/src/constants/storage_keys.dart';
import 'package:quitanda_app/src/models/user_model.dart';
import 'package:quitanda_app/src/pages/auth/repository/auth_repository.dart';
import 'package:quitanda_app/src/pages/auth/result/auth_result.dart';
import 'package:quitanda_app/src/pages_routes/app_pages.dart';
import 'package:quitanda_app/src/services/utils_services.dart';

class AuthController extends GetxController {
  RxBool isLoading = false.obs;

  final authRepository = AuthRepository();
  final utilsServices = UtilsServices();

  UserModel user = UserModel();

  @override
  void onInit() {
    super.onInit();

    validateToken();
  }

  Future<void> validateToken() async {
    //Recuperar token salvo localmente

    String? token = await utilsServices.getLocalData(key: StorageKeys.token);

    if (token == null) {
      Get.offAllNamed(PagesRoutes.signInRoute);
      return;
    }
    AuthResult result = await authRepository.validateToken(token);

    result.when(sucess: (user) {
      this.user = user;
      savedTokenAndProceedBase();
    }, error: (message) {
      signOut();
    });
  }

  Future<void> resetPassword(String email) async {
    await authRepository.resetPassword(email);
  }

  Future<void> signOut() async {
    //Zerar o user
    user = UserModel();

    //remover o token localmente
    await utilsServices.removeLocalData(key: StorageKeys.token);

    //Ir para o login
    Get.offAllNamed(PagesRoutes.signInRoute);
  }

  void savedTokenAndProceedBase() {
    //Salvar Token
    utilsServices.saveLocalData(key: StorageKeys.token, data: user.token!);

    Get.offAndToNamed(PagesRoutes.baseRoute);
  }

  Future<void> signUp() async {
    isLoading.value = true;

    AuthResult result = await authRepository.signUp(user);

    isLoading.value = false;

    result.when(sucess: (user) {
      this.user = user;
      savedTokenAndProceedBase();
    }, error: (message) {
      utilsServices.showToast(
        message: message,
        isError: true,
      );
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    isLoading.value = true;

    AuthResult result =
        await authRepository.signin(email: email, password: password);

    isLoading.value = false;

    result.when(
      sucess: (user) {
        this.user = user;

        savedTokenAndProceedBase();
      },
      error: (message) {
        utilsServices.showToast(
          message: message,
          isError: true,
        );
        print(message);
      },
    );
  }
}
