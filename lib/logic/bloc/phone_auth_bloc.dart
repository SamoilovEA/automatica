import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/data/user_model.dart';
import 'package:flutter_maps/logic/bloc/phone_auth_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class FirebaseAuthAppCubit extends Cubit<FirebaseAuthAppState> {
  String countryKey = '+7';
  late String verificationCode;

  static FirebaseAuthAppCubit get(context) => BlocProvider.of(context);

  FirebaseAuthAppCubit() : super(PhoneAuthInitial());

  Future<void> submitUserPhoneNumber(String phoneNum) async {
    emit(PhoneAuthLoading());
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "$countryKey$phoneNum",
        verificationCompleted: verificationCompleted,
        timeout: const Duration(seconds: 25),
        verificationFailed: verificationFailed,
        codeSent: codeSentToUser,
        codeAutoRetrievalTimeout: (String verificationId) {});
  }

  void verificationCompleted(PhoneAuthCredential credential) async {
    await userSignIn(credential);
  }

  void verificationFailed(FirebaseAuthException exception) {
    emit(PhoneAuthErrorOccurred(message: exception.toString()));
  }

  void codeSentToUser(String verificationID, int? reSentCode) {
    verificationCode = verificationID;
    emit(PhoneNumberSubmitted());
  }

  Future<void> submitOtbCode(String otpCode) async {
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verificationCode, smsCode: otpCode);

    await userSignIn(phoneAuthCredential);
  }

  Future<void> userSignIn(PhoneAuthCredential credential) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      emit(PhoneOtpCodeVerified());
    } catch (error) {
      emit(PhoneAuthErrorOccurred(message: error.toString()));
    }
  }

  Future userSignOut() async {
    emit(UserSignOutLoading());
    await FirebaseAuth.instance.signOut().whenComplete(() {
      emit(UserSignOutSuccess());
    }).onError((error, stackTrace) {
      emit(UserSignUpError(errorMessage: error.toString()));
    });
  }

  User? getUserInfo() {
    User? user = FirebaseAuth.instance.currentUser;
    return user;
  }

  String getUserID() {
    var userID = FirebaseAuth.instance.currentUser!.uid;
    return userID;
  }

  late UserModel userModel;
  IconData suffix = Icons.visibility_outlined;

  bool isPasswordShowing = true;
  void changePasswordVisibility() {
    isPasswordShowing = !isPasswordShowing;
    suffix = isPasswordShowing
        ? Icons.visibility_off_outlined
        : Icons.visibility_outlined;

    emit(ChangePasswordVisibilityState());
  }

  String? signInType;

  void createNewUser({required String id, required String phone}) {
    emit(CreateNewUserLoading());

    userModel = UserModel(
      phone: phone,
      uId: id,
    );
    FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userModel.toMap())
        .then((value) {
      emit(CreateNewUserSuccess());
    }).catchError((onError) {
      emit(CreateNewUserError(errorMessage: onError.toString()));
    });
  }

  void getCurrentUserInfo() {
    emit(GetUserInfoLoadingStatus());
    FirebaseFirestore.instance
        .collection('users')
        .doc(getUserID())
        .get()
        .then((value) {
      userModel = UserModel.fromJson(value.data());
      emit(GetUserInfoSuccessStatus());
    }).catchError((onError) {
      emit(GetUserInfoErrorStatus(errorMessage: onError.toString()));
    });
  }

  //Gallery

  var user = FirebaseAuth.instance.currentUser;

  FirebaseStorage storage = FirebaseStorage.instance;
  Future<void> upload(String inputSource) async {
    final picker = ImagePicker();
    PickedFile? pickedImage;
    try {
      pickedImage = await picker.getImage(
          source: inputSource == 'camera'
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: 1920);

      final String fileName = path.basename(pickedImage!.path);
      File imageFile = File(pickedImage.path);

      try {
        log(user!.uid.toString());
        await storage.ref('${user!.uid}/$fileName').putFile(
            imageFile,
            SettableMetadata(customMetadata: {
              'uploaded_by': 'A bad guy',
              'description': 'Some description...'
            }));
      } on FirebaseException catch (error) {
        log(error.toString());
      }
      loadImages();
    } catch (err) {
      log(err.toString());
    }
  }

  Future<void> loadImages() async {
    emit(GalleryLoading());
    List<Map<String, dynamic>> files = [];

    final ListResult result =
        await storage.ref(FirebaseAuth.instance.currentUser!.uid).list();
    final List<Reference> allFiles = result.items;
    try {
      await Future.forEach<Reference>(allFiles, (file) async {
        final String fileUrl = await file.getDownloadURL();
        // final FullMetadata fileMeta = await file.getMetadata();
        files.add({
          "url": fileUrl,
          "path": file.fullPath,
        });
      });
      emit(GalleryLoaded(images: files));
    } catch (err) {
      log(err.toString());
    }

    // return files;
  }

  // Delete the selected image
  // This function is called when a trash icon is pressed
  Future<void> delete(
    BuildContext context,
    String ref,
  ) async {
    await storage.ref(ref).delete();
    // await loadImages();
  }
}
