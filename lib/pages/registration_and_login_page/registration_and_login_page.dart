import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/widgets/general_app_bar.dart';
import 'package:qurantafsir_flutter/widgets/registration_view/registration_view.dart';

class RegistrationAndLoginPageParam {
  RegistrationAndLoginPageParam({this.shouldNavigateTabToHome = true});

  final bool shouldNavigateTabToHome;
}

class RegistrationAndLoginPage extends StatelessWidget {
  const RegistrationAndLoginPage({super.key, this.param});

  final RegistrationAndLoginPageParam? param;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GeneralAppBar(title: 'Settings'),
      body: SingleChildScrollView(
        child: RegistrationView(
          shouldNavigateTabToHome: param?.shouldNavigateTabToHome ?? true,
          onSuccessLogin: () {
            const bool isLoggedIn = true;
            Navigator.pop(context, isLoggedIn);
          },
        ),
      ),
    );
  }
}
