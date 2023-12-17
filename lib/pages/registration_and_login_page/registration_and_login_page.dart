import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/widgets/registration_view/registration_view.dart';

class RegistrationAndLoginPageParam {
  RegistrationAndLoginPageParam({
    this.shouldNavigateTabToHome = true,
  });

  final bool shouldNavigateTabToHome;
}

class RegistrationAndLoginPage extends StatelessWidget {
  const RegistrationAndLoginPage({
    super.key,
    this.param,
  });

  final RegistrationAndLoginPageParam? param;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(54.0),
        child: AppBar(
          elevation: 0.7,
          foregroundColor: Theme.of(context).colorScheme.primary,
          centerTitle: true,
          title: const Text(
            'Settings',
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: QPColors.getColorBasedTheme(
                dark: QPColors.whiteFair,
                light: QPColors.blackMassive,
                brown: QPColors.brownModeMassive,
                context: context,
              ),
              size: 24,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          automaticallyImplyLeading: false,
        ),
      ),
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
