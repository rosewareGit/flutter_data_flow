import '../../../../api/collections/item_change.dart';
import '../../../../api/collections/map/change.dart';
import '../../../../api/collections/map/observable.dart';
import '../../../../api/collections/map/update_action.dart';
import '../../../../api/observable.dart';
import 'transform.dart';

class OperatorMapFactory<K, V> extends OperatorMapTransform<K, V, K, V> {
  OperatorMapFactory({
    required final FactoryMap<K, V> factory,
    required super.source,
  }) : super(factory: factory);

  @override
  void transformChange(
    final ObservableMap<K, V> state,
    final ObservableMapChange<K, V> change,
    final Emitter<ObservableMapUpdateAction<K, V>> updater,
  ) {
    final Map<K, V> addItems = Map<K, V>.fromEntries(<MapEntry<K, V>>[
      ...change.added.entries,
      ...change.updated
          .map(
            (final K key, final ObservableItemChange<V> value) => MapEntry<K, V>(
              key,
              value.newValue,
            ),
          )
          .entries,
    ]);
    final Set<K> removeKey = <K>{...change.removed.keys};
    updater.call(
      ObservableMapUpdateAction<K, V>(
        addItems: addItems,
        removeItems: removeKey,
      ),
    );
  }
}
