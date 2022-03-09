import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/framework.dart';
import 'package:qurantafsir_flutter/shared/core/view_models/base_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewModelConnector<T extends BaseViewModel<P>, P>
    extends ConsumerStatefulWidget {
  const ViewModelConnector({
    required this.builder,
    required this.viewModelProvider,
    Key? key,
    this.child,
    this.onViewModelReady,
  }) : super(key: key);

  final Widget Function(
    BuildContext context,
    P state,
    T notifier,
    Widget? child,
  ) builder;
  final StateNotifierProvider<T, P> viewModelProvider;
  final Widget? child;
  final void Function(T)? onViewModelReady;

  @override
  _ViewModelConnectorState<T, P> createState() => _ViewModelConnectorState();
}

class _ViewModelConnectorState<T extends BaseViewModel<P>, P>
    extends ConsumerState<ViewModelConnector<T, P>> with RouteAware {
  @override
  void initState() {
    final T notifier = ref.read(widget.viewModelProvider.notifier);
    widget.onViewModelReady?.call(notifier);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final P state = ref.watch(widget.viewModelProvider);
    final T notifier = ref.watch(widget.viewModelProvider.notifier);

    return widget.builder(
      context,
      state,
      notifier,
      widget.child,
    );
  }
}
