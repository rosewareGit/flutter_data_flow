import '../../../../../../dart_observable.dart';
import '../../../../../api/change_tracking_observable.dart';
import '../../../set/stateful/failure/rx_impl.dart';
import '../../_base_transform.dart';

class SetFailureImpl<Self extends ChangeTrackingObservable<Self, CS, C>, F, E2, C, CS> extends RxSetFailureImpl<E2, F>
    with
        BaseCollectionTransformOperator<
            Self,
            ObservableSetFailure<E2, F>,
            CS, //
            ObservableSetStatefulState<E2, F>,
            C,
            StateOf<ObservableSetChange<E2>, F>,
            StateOf<ObservableSetUpdateAction<E2>, F>> {
  @override
  final Self source;

  final void Function(
    ObservableSetFailure<E2, F> state,
    C change,
    Emitter<StateOf<ObservableSetUpdateAction<E2>, F>> updater,
  ) transformFn;

  SetFailureImpl({
    required this.source,
    required this.transformFn,
    final FactorySet<E2>? factory,
  }) : super(factory: factory);

  @override
  void transformChange(
    final C change,
    final Emitter<StateOf<ObservableSetUpdateAction<E2>, F>> updater,
  ) {
    transformFn(this, change, updater);
  }
}
