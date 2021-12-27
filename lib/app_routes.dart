import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/constants/strings.dart';
import 'package:flutter_maps/presentaion/screens/reset_code_sent.dart';
import 'package:flutter_maps/presentaion/screens/verify_user_phone.dart';
import 'package:flutter_maps/presentaion/screens/user_profile.dart';
import 'logic/bloc/phone_auth_bloc.dart';
import 'presentaion/screens/phone_auth.dart';
import 'presentaion/screens/splash_screen.dart';

class AppRouter {
  late FirebaseAuthAppCubit phoneAuthCubit;
  AppRouter() {
    phoneAuthCubit = FirebaseAuthAppCubit();
  }
  Route generateRoute(RouteSettings routeSettings) {
    final authType = routeSettings.arguments;
    switch (routeSettings.name) {
      case splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case userResetCodeSentScreen:
        return MaterialPageRoute(
            builder: (_) => BlocProvider<FirebaseAuthAppCubit>.value(
                  value: phoneAuthCubit,
                  child: ResetCodeSent(),
                ));

      case phoneAuthScreen:
        return MaterialPageRoute(
            builder: (_) => BlocProvider<FirebaseAuthAppCubit>.value(
                  value: phoneAuthCubit,
                  child: PhoneAuthScreen(),
                ));

      case verifyPhoneScreen:
        return MaterialPageRoute(
            builder: (_) => BlocProvider<FirebaseAuthAppCubit>.value(
                  value: phoneAuthCubit,
                  child: VerifyPhoneNumber(
                    phoneNumber: authType.toString(),
                  ),
                ));

      // case createAccountScreen:
      //   return MaterialPageRoute(
      //       builder: (_) => BlocProvider<FirebaseAuthAppCubit>.value(
      //             value: phoneAuthCubit,
      //             child: CreateUserAccount(
      //               signInType: authType.toString(),
      //             ),
      //           ));

      case userProfileScreen:
        return MaterialPageRoute(
            builder: (_) => BlocProvider<FirebaseAuthAppCubit>.value(
                  value: phoneAuthCubit,
                  child: UserProfileScreen(
                    signInType: authType.toString(),
                  ),
                ));
      default:
        {
          return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
    }
  }
}
