import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

import '../../services/auth.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthServices authRepository;
  AuthBloc({@required this.authRepository}) : super(UnAuthenticated()) {
    // When User Presses the SignIn Button, we will send the SignInRequested Event to the AuthBloc to handle it and emit the Authenticated State if the user is authenticated
    on<SignInRequested>((event, emit) async {
      emit(Loading());
      try {
        User user = await authRepository.signInWithEmailAndPassword(
            email: event.email, password: event.password);
        if (user != null) {
          emit(Authenticated());
        } else {
          throw Exception('wrong-password');
        }
      } catch (e) {
        String errorMsg = e.toString();
        if (e.message == 'user-not-found') {
          errorMsg = 'No user found for that email.';
        } else if (e.message == 'wrong-password') {
          errorMsg = 'Wrong password provided for that user.';
        }
        emit(AuthError(errorMsg));
        emit(UnAuthenticated());
      }
    });
    // When User Presses the SignUp Button, we will send the SignUpRequest Event to the AuthBloc to handle it and emit the Authenticated State if the user is authenticated
    on<SignUpRequested>((event, emit) async {
      emit(Loading());
      try {
        await authRepository.createUserWithEmailAndPassword(
            email: event.email,
            password: event.password,
            name: event.name,
            breed: event.breed,
            dateTime: event.dateTime,
            currentDate: event.currentDate);
        emit(Authenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
        emit(UnAuthenticated());
      }
    });
    // When User Presses the Google Login Button, we will send the GoogleSignInRequest Event to the AuthBloc to handle it and emit the Authenticated State if the user is authenticated
    on<GoogleSignInRequested>((event, emit) async {
      emit(Loading());
      try {
        await authRepository.signInWithGoogle();
        emit(Authenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
        emit(UnAuthenticated());
      }
    });
    // When User Presses the Facebook Login Button, we will send the FacebookSignInRequest Event to the AuthBloc to handle it and emit the Authenticated State if the user is authenticated
    on<FacebookSignInRequested>((event, emit) async {
      emit(Loading());
      try {
        await authRepository.signInWithFacebook();
        emit(Authenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
        emit(UnAuthenticated());
      }
    });
    // When User Presses the SignOut Button, we will send the SignOutRequested Event to the AuthBloc to handle it and emit the UnAuthenticated State
    on<SignOutRequested>((event, emit) async {
      emit(Loading());
      await authRepository.signOut();
      emit(UnAuthenticated());
    });
  }
}
