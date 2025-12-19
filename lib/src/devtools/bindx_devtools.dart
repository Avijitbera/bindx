import 'package:bindx/src/core/bindx_registry.dart';
import 'package:flutter/material.dart';

class BindXDevTools extends StatefulWidget {
  final bool showRegistry;
  final bool showStoreDetails;
  const BindXDevTools({
    Key? key,
    this.showRegistry = true,
    this.showStoreDetails = true,
  }) : super(key: key);

  @override
  State<BindXDevTools> createState() => _BindXDevToolsState();
}

class _BindXDevToolsState extends State<BindXDevTools> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('BindX DevTools')),
        body: ListView(
          children: [
            if (widget.showRegistry) _buildRegistryView(),
            if (widget.showStoreDetails) _buildStoreDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistryView() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Store Registry",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            StreamBuilder(
              stream: Stream.periodic(Duration(seconds: 1)),
              builder: (context, snapshot) {
                return Column(
                  children: bindxRegistry.stores.entries.map((entry) {
                    final type = entry.key;
                    final stores = entry.value;

                    return ListTile(
                      title: Text(type.toString()),
                      subtitle: Text('${stores.length} instance(s)'),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle),
                        onPressed: () {
                          bindxRegistry.remove(type: type);
                          setState(() {});
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreDetails() {
    // Implementation for detailed store inspection
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Store Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Select a store to view details'),
          ],
        ),
      ),
    );
  }
}
