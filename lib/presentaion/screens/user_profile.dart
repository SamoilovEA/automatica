import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/constants/colors.dart';
import 'package:flutter_maps/constants/strings.dart';
import 'package:flutter_maps/data/user_model.dart';
import 'package:flutter_maps/logic/bloc/phone_auth_bloc.dart';
import 'package:flutter_maps/logic/bloc/phone_auth_state.dart';
import 'package:flutter_maps/presentaion/widget/loading_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hexcolor/hexcolor.dart';

// ignore: must_be_immutable
class UserProfileScreen extends StatefulWidget {
  String signInType;
  UserProfileScreen({Key? key, required this.signInType}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  var etPhoneController = TextEditingController();

  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    FirebaseAuthAppCubit.get(context).userModel = UserModel(uId: '', phone: '');
    FirebaseAuthAppCubit.get(context).getCurrentUserInfo();
    FirebaseAuthAppCubit.get(context).loadImages();
    return BlocConsumer<FirebaseAuthAppCubit, FirebaseAuthAppState>(
        listener: (context, state) {
      if (state is GetUserInfoErrorStatus) {
        String errorMeg = state.errorMessage;
        showFlushBar(context, errorMeg, "Error");
      }
    }, builder: (context, state) {
      var userModel = FirebaseAuthAppCubit.get(context).userModel;
      return Scaffold(
        backgroundColor: CustomColors.backgroundColor,
        body: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            if (state is UpdateCurrentUserInfoLoading)
              LinearProgressIndicator(
                minHeight: 10,
                color: CustomColors.googleBackground,
                backgroundColor: CustomColors.colorOrange,
              ),
            if (state is GetUserInfoLoadingStatus)
              LinearProgressIndicator(
                minHeight: 10,
                color: CustomColors.googleBackground,
                backgroundColor: CustomColors.colorOrange,
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: buildTextViewShape(context, userModel.phone, 20, false,
                      FontAwesomeIcons.phoneSquare),
                ),
                Align(
                  alignment: AlignmentDirectional.topStart,
                  child: IconButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        barrierDismissible: false, // user must tap button!
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Log off?'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('No'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text('Yes'),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  await FirebaseAuthAppCubit.get(context)
                                      .userSignOut();
                                  Navigator.pushReplacementNamed(
                                      context, splashScreen);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(
                      Icons.logout,
                      size: 30,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            if (state is GalleryLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            createUserStates(),
            if (state is GalleryLoaded)
              Flexible(
                child: GridView.builder(
                  cacheExtent: 9999,
                  padding: EdgeInsets.zero,
                  itemCount: state.images.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemBuilder: (context, index) {
                    final Map<String, dynamic> image = state.images[index];
                    log(image['url']);
                    return Stack(
                      children: [
                        Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 5),
                          child: Image.network(image['url']),
                        ),
                        IconButton(
                          onPressed: () async {
                            await showDialog<void>(
                              context: context,
                              barrierDismissible:
                                  false, // user must tap button!
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Delete?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('No'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Yes'),
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        await FirebaseAuthAppCubit()
                                            .delete(context, image['path']);
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: CustomColors.colorOrange,
          onPressed: () async {
            await showDialog<void>(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Upload Photos'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Gallery'),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await FirebaseAuthAppCubit.get(context)
                            .upload('gallery');
                        setState(() {});
                      },
                    ),
                    TextButton(
                      child: const Text('Camera'),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await FirebaseAuthAppCubit.get(context)
                            .upload('camera');
                        setState(() {});
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: const Icon(Icons.add),
        ),
      );
    });
  }

  Widget buildTextViewShape(BuildContext context, String text, double textSize,
      bool isTextBio, IconData iconData) {
    return Container(
      width: double.infinity,
      height: 60,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: HexColor("2C313C"),
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        border: Border.all(
          color: CustomColors.googleBackground,
          width: 1,
        ),
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Row(
          children: [
            const SizedBox(
              width: 5,
            ),
            Icon(iconData, size: 22, color: CustomColors.colorAmber),
            const SizedBox(
              width: 5,
            ),
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.justify,
                overflow: TextOverflow.ellipsis,
                maxLines: 4,
                style: TextStyle(
                    fontSize: textSize,
                    letterSpacing: 1.0,
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.w600,
                    color: CustomColors.colorGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget createUserStates() {
    return BlocListener<FirebaseAuthAppCubit, FirebaseAuthAppState>(
      listenWhen: (previous, current) {
        return previous != current;
      },
      listener: (context, state) {
        if (state is UserSignOutLoading) {
          Navigator.pop(context);
          showLoadingDialog(context);
        }
        if (state is UserSignOutSuccess) {
          Navigator.pushReplacementNamed(context, phoneAuthScreen);
          showFlushBar(context, "Sign Out Finished Successfully", "Error");
        }
        if (state is UserLoginErrorState) {
          Navigator.pop(context);
          String errorMeg = state.errorMessage;
          showFlushBar(context, errorMeg, "Error");
        }
      },
      child: Container(),
    );
  }
}
