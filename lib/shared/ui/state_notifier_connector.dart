import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StateNotifierConnector<T extends StateNotifier<P>, P>
    extends ConsumerStatefulWidget {
  const StateNotifierConnector({
    required this.builder,
    required this.stateNotifierProvider,
    Key? key,
    this.child,
    this.onStateNotifierReady,
  }) : super(key: key);

  final Widget Function(
    BuildContext context,
    P state,
    T notifier,
    WidgetRef ref,
  ) builder;
  final StateNotifierProvider<T, P> stateNotifierProvider;
  final Widget? child;
  final void Function(T, WidgetRef)? onStateNotifierReady;

  @override
  _StateNotifierConnectorState<T, P> createState() =>
      _StateNotifierConnectorState();
}

class _StateNotifierConnectorState<T extends StateNotifier<P>, P>
    extends ConsumerState<StateNotifierConnector<T, P>> with RouteAware {
  @override
  void initState() {
    final T notifier = ref.read(widget.stateNotifierProvider.notifier);
    widget.onStateNotifierReady?.call(notifier, ref);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final P state = ref.watch(widget.stateNotifierProvider);
    final T notifier = ref.watch(widget.stateNotifierProvider.notifier);

    return widget.builder(
      context,
      state,
      notifier,
      ref,
    );
  }
}
