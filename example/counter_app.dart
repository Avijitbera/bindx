import 'package:flutter/material.dart';
import 'package:bindx/bindx.dart';

// State
class CounterState {
  final int count;
  final bool isLoading;

  const CounterState({this.count = 0, this.isLoading = false});

  CounterState copyWith({int? count, bool? isLoading}) {
    return CounterState(
      count: count ?? this.count,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Store
class CounterStore extends BindXStore<CounterState> {
  CounterStore() : super(const CounterState());

  Future<void> increment() async {
    await update((current) => current.copyWith(count: current.count + 1));
  }

  Future<void> decrement() async {
    await update((current) => current.copyWith(count: current.count - 1));
  }

  Future<void> reset() async {
    await update((current) => const CounterState());
  }

  @Cache(duration: Duration(seconds: 5))
  Future<int> getDoubleCount() async {
    // Simulating expensive computation
    await Future.delayed(const Duration(milliseconds: 500));
    return state.count * 2;
  }
}

// App
void main() {
  runApp(const CounterApp());
}

class CounterApp extends StatelessWidget {
  const CounterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BindXProvider<CounterStore>(
      store: CounterStore(),
      child: MaterialApp(
        title: 'BindX Counter Example',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const CounterPage(),
      ),
    );
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = BindXProvider.of<CounterStore>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BindX Counter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => store.reset(),
            tooltip: 'Reset',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You have pushed the button this many times:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              '${store.state.count}',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            FutureBuilder<int>(
              future: store.getDoubleCount(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                return Text(
                  'Double: ${snapshot.data ?? 0}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: () => store.decrement(),
                  tooltip: 'Decrement',
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  onPressed: () => store.increment(),
                  tooltip: 'Increment',
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const _CounterStreamWidget(),
          ],
        ),
      ),
    );
  }
}

class _CounterStreamWidget extends StatelessWidget {
  const _CounterStreamWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = BindXProvider.of<CounterStore>(context, listen: false);

    return Card(
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Stream Update:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            StreamBuilder<CounterState>(
              stream: store.stream,
              initialData: store.state,
              builder: (context, snapshot) {
                return Text(
                  'Count from stream: ${snapshot.data?.count ?? 0}',
                  style: const TextStyle(fontSize: 16),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
