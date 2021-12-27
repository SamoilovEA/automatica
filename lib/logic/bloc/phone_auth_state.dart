abstract class FirebaseAuthAppState {}

class PhoneAuthInitial extends FirebaseAuthAppState {}

class PhoneAuthLoading extends FirebaseAuthAppState {}

class PhoneAuthErrorOccurred extends FirebaseAuthAppState {
  final String message;

  PhoneAuthErrorOccurred({required this.message});
}

class PhoneNumberSubmitted extends FirebaseAuthAppState {}

class PhoneOtpCodeVerified extends FirebaseAuthAppState {}

class ChangePasswordVisibilityState extends FirebaseAuthAppState {}

class UserLoginLoadingState extends FirebaseAuthAppState {}

class UserLoginSuccessState extends FirebaseAuthAppState {
  final String userID;
  UserLoginSuccessState({required this.userID});
}

class UserLoginErrorState extends FirebaseAuthAppState {
  final String errorMessage;
  UserLoginErrorState({required this.errorMessage});
}

class UserSignUpLoading extends FirebaseAuthAppState {}

class UserSignUpSuccess extends FirebaseAuthAppState {}

class UserSignUpError extends FirebaseAuthAppState {
  final String errorMessage;

  UserSignUpError({required this.errorMessage});
}

class UserSignOutLoading extends FirebaseAuthAppState {}

class UserSignOutSuccess extends FirebaseAuthAppState {}

class UserSignOutError extends FirebaseAuthAppState {
  final String errorMessage;

  UserSignOutError({required this.errorMessage});
}

class CreateNewUserLoading extends FirebaseAuthAppState {}

class CreateNewUserSuccess extends FirebaseAuthAppState {}

class CreateNewUserError extends FirebaseAuthAppState {
  final String errorMessage;

  CreateNewUserError({required this.errorMessage});
}


class GetUserInfoLoadingStatus extends FirebaseAuthAppState {}

class GetUserInfoSuccessStatus extends FirebaseAuthAppState {}

class GetUserInfoErrorStatus extends FirebaseAuthAppState {
  final String errorMessage;

  GetUserInfoErrorStatus({required this.errorMessage});
}

class UpdateUserInfo extends FirebaseAuthAppState{}

class UpdateCurrentUserInfoLoading extends FirebaseAuthAppState{}
class UpdateCurrentUserInfoSuccess extends FirebaseAuthAppState{}
class UpdateCurrentUserInfoError extends FirebaseAuthAppState{
  final String errorMessage;

  UpdateCurrentUserInfoError({required this.errorMessage});
}

class GalleryInitial extends FirebaseAuthAppState {}

class GalleryLoading extends FirebaseAuthAppState {}

class GalleryLoaded extends FirebaseAuthAppState {
  final List<Map<String, dynamic>> images;

  GalleryLoaded({required this.images});
}

class GalleryError extends FirebaseAuthAppState {
  final String message;

  GalleryError({required this.message});
}