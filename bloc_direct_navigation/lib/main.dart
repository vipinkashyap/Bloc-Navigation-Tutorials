/// Two pages that point to each other PageA, PageB
/// Two events, both of which are button clicks triggering events A and B
/// Two states, A and B being emitted by their respective events

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events being defined
enum MyEvent { eventA, eventB }

// States being defined
abstract class MyState {}

class StateA extends MyState {}

class StateB extends MyState {}

// Bloc being defined

class MyBloc extends Bloc<MyEvent, MyState> {
  MyBloc() : super(StateA()) {
    on<MyEvent>(_onMyEvent);
  }
  void _onMyEvent(MyEvent event, Emitter<MyState> emit) {
    switch (event) {
      case MyEvent.eventA:
        emit(StateA());
        break;
      case MyEvent.eventB:
        emit(StateB());
        break;
      default:
        emit(StateA());
    }
  }
}

// Bloc observer being defined
class MyBlocObserver extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    log('Bloc: $bloc \n Transition: $transition');
    super.onTransition(bloc, transition);
  }
}

void main() {
  BlocOverrides.runZoned(() => runApp(const MyApp()),
      blocObserver: MyBlocObserver());
}

// Providing MyBloc to the app
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyBloc(),
      child: MaterialApp(
        title: 'Bloc Direct Navigation',
        home: BlocBuilder<MyBloc, MyState>(
            builder: (context, state) =>
                state is StateA ? const PageA() : const PageB()),
      ),
    );
  }
}

// Defining the two pages

class PageA extends StatelessWidget {
  const PageA({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page A')),
      body: Center(
          child: MaterialButton(
        color: Colors.grey.shade400,
        child: const Text('Page B'),
        onPressed: () => context.read<MyBloc>().add(MyEvent.eventB),
      )),
    );
  }
}

class PageB extends StatelessWidget {
  const PageB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page B')),
      body: Center(
          child: MaterialButton(
        color: Colors.grey.shade400,
        child: const Text('Page A'),
        onPressed: () => context.read<MyBloc>().add(MyEvent.eventA),
      )),
    );
  }
}
