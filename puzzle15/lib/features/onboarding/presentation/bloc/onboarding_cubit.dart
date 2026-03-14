import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingState {
  const OnboardingState({required this.index, required this.completed});

  final int index;
  final bool completed;

  OnboardingState copyWith({int? index, bool? completed}) {
    return OnboardingState(
      index: index ?? this.index,
      completed: completed ?? this.completed,
    );
  }
}

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingState(index: 0, completed: false));

  void next(int max) {
    if (state.index < max - 1) {
      emit(state.copyWith(index: state.index + 1));
    } else {
      emit(state.copyWith(completed: true));
    }
  }

  void back() {
    if (state.index > 0) {
      emit(state.copyWith(index: state.index - 1));
    }
  }
}
