# About

Observable follows the reactive programming paradigm, offering a straightforward yet powerful way to manage state in Dart applications.

- **Change Tracking**: It supports tracking changes in collections like sets, maps, or lists, enabling developers to build reactive applications with ease.
- **Factories and Operators**: The library includes a variety of factories and operators.
- **Cold Observables**: All observables are cold by default, meaning they only emit values when actively listened to.
- **Mutable and Immutable Versions**: The library offers both mutable and immutable versions of observables, including for collections.

## Observable
- The base class for all observables. Immutable version of the observable. `Rx` is the mutable version, which implements the `Observable` interface.
- The observable can be listened to by multiple listeners.
```
Rx<int> _rxNumber = Rx<int>(1);
Observable<int> get rxNumber => _rxNumber; 
```

### Factories

- **just**
  - Creates an observable with a single value. 
  - ```
    final Observable<int> rxInt = Observable<int>.just(0);
    ```
- **combineLatest**
  - Combines multiple observables into a single observable.
  - ```
     final Rx<int> rxInt1 = Rx<int>(0);
     final Rx<int> rxInt2 = Rx<int>(0);
     final Rx<int> rxInt3 = Rx<int>(0);

     final Observable<int> rxInt = Observable<int>.combineLatest(
       observables: <Observable<int>>[rxInt1, rxInt2, rxInt3],
       combiner: () {
         return rxInt1.value + rxInt2.value + rxInt3.value;
        },
     );
    ```
- **fromFuture**
    - Creates an observable from a future.
    - ```
      final Future<int> future = Future<int>.value(10);
      final Observable<int> rxInt = Observable<int>.fromFuture(
          initial: 0,
          future: future,
      );
      ```
- **fromStream**
    - Creates an observable from a stream, listening to the stream and updating the observable.
    - ```
      final Stream<int> stream = Stream<int>.value(10);
      final Observable<int> rxInt = Observable<int>.fromStream(
          initial: 0,
          stream: stream,
      );
      ```

### Operators

- **map**
  - Transforms the value of the observable.
  - ```
    Observable<int> rxSource = Observable<int>.just(0);
    Observable<String> rxString = rxSource.map((value) => value.toString());
    ```
- **filter**
    - Filters the value of the observable
    - ```
      Observable<int> rxSource = Observable<int>.just(0);
      Observable<int> rxFiltered = rxSource.filter((value) => value % 2 == 0);
      ```
- **combineWith**
    - Combines the observable with another observable.
    - ```
      final Rx<int> observable1 = Rx<int>(1);
      final Rx<int> observable2 = Rx<int>(2);
      final Observable<int> combined = observable1.combineWith<int, int>(
        other: observable2,
        combiner: (final int value1, final int value2) => value1 + value2,
      );
      ```
- **handleError**
    - Handles errors in the observable. Provides a way to recover from errors.
    - Accept an optional predicate to filter the errors.
    - ```
      final Observable<int> rxInt = Observable<int>.just(0);
      final Observable<int> rxIntHandled = rxInt.handleError(
        (final dynamic error, final Emitter<int> emit) {
          emit(1);
        },
        predicate: (final dynamic error) {
          return error is ArgumentError;
        });
      ```
- **transform**
    - The most flexible operator that allows the user to transform the observable in any way.
    - Emitter is used to emit any new value to the observable.
    - ```
      final Rx<int> rx = Rx<int>(0);
      final Observable<double> transformed = rx.transform<double>(
        initialProvider: (final int value) {
          return value * 2.5;
        },
        onChanged: (
          final int value,
          final Emitter<double> emitter,
        ) {
          emitter(value * 2.5);
        },
      );
        ```
- **transformAs**
  - Used to transform the observable to a new collection.
  - ```
          final Rx<String> rxSource = Rx<String>('Hello World');
          final ObservableList<String> rxTransformed = rxSource.transformAs.list<String>(
            transform: (
              final ObservableList<String> state,
              final String value,
              final Emitter<List<String>> emitter,
            ) {
              emitter(<String>[for (final String char in value.split('')) char]);
            },
          );
    ```
- **switchMap**
  - On each change, switch to a new observable provided by the mapper function.
  - Cancels the previous observable, and listens to the new observable.
  - ```
    final RxInt rxType1 = RxInt(1);
    final RxInt rxType2 = RxInt(2);
    final RxInt rxType3 = RxInt(3);
    final RxList<int> rxSource = RxList<int>(<int>[1, 2, 3]);
    final Observable<int> rxSwitched = rxSource.switchMap<int>(
          (final List<int> state) {
            final int mod = state.length % 3;
            if (mod == 0) {
              return rxType1;
            } else if (mod == 1) {
              return rxType2;
            } else {
              return rxType3;
            }
          },
        );
    ```
- **switchMapAs**
  - On each change, switch to a new collection provided by the mapper function.
  - Cancels the previous observable, and listens to the new observable.
  - ```
          final RxMap<int, String> rxType1 = RxMap<int, String>(<int, String>{1: '1'});
          final RxMap<int, String> rxType2 = RxMap<int, String>(<int, String>{2: '2'});
          final RxMap<int, String> rxType3 = RxMap<int, String>(<int, String>{3: '3'});
          final Rx<int> rxSource = Rx<int>(0);
          final ObservableMap<int, String> rxSwitched = rxSource.switchMapAs.map<int, String>(
            mapper: (final int value) {
              final int mod = value % 3;
              if (mod == 0) {
                return rxType1;
              } else if (mod == 1) {
                return rxType2;
              } else {
                return rxType3;
              }
            },
          );
    ```


## Collections

Currently `list`, `set` and `map` are supported.
When the collection is modified, the observable will emit the change which can be listened by the subscribers.
The change is used in the operators to transform only the changed values.

Example:
Adding a value to a list with 10.000 items will only emit the added value.  
Listeners can use the change to transform that value.  
In the following example, the initial list will be only transformed once, when the observable is listened.
After that, only the change will be transformed.

``` 
RxList<int> rxLargeList = RxList<int>(List.generate(10000, (index) => index));
ObservableList<int> rxEvenItems = rxLargeList.filterItem((final int item) => item % 2 == 0);
ObservableList<int> rxEvenItemsMapped = rxEvenItems.mapItem((final int item) => item * 2);
rxLargeList.add(10000);
rxLargeList.removeAt(0);
```

## Stateful Collections

Stateful collections support custom states, such as loading, error, or any user-defined state.
Combines both the collection and the custom state, allowing the observable to represent either at any given time.
This approach eliminates the need for multiple observables to manage different states. For example, when fetching a list of items from a server, the observable can represent loading, error, or data states within a single unified state.
```
ObservableStatefulList<String, LoadingOrError> rxItems = getItemsFromServer();
rxItems.listen(onChange: (state) {
  state.when(
    onData: (ObservableListState<String> items) => , // Items loaded,
    onCustom: (LoadingOrError state) => , // Custom state,
  );
});
```

