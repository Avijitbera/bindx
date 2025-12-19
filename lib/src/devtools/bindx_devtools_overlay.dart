import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'bindx_devtools.dart';

class BindXDevToolsOverlay extends StatefulWidget {
  final Widget child;
  final bool enabled;
  const BindXDevToolsOverlay({
    Key? key,
    required this.child,
    this.enabled = !kReleaseMode,
  }) : super(key: key);

  @override
  State<BindXDevToolsOverlay> createState() => _BindXDevToolsOverlayState();
}

class _BindXDevToolsOverlayState extends State<BindXDevToolsOverlay> {
  bool _showDevTools = false;
  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return Stack(
      children: [
        widget.child,
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            mini: true,
            onPressed: () {
              setState(() {
                _showDevTools = !_showDevTools;
              });
            },
            child: Icon(_showDevTools ? Icons.close : Icons.bug_report),
          ),
        ),
        if (_showDevTools)
          Positioned.fill(
            child: DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.3,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Card(
                  elevation: 8,
                  child: Column(
                    children: [
                      AppBar(
                        title: Text('NexusState DevTools'),
                        leading: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _showDevTools = false;
                            });
                          },
                        ),
                      ),
                      Expanded(child: BindXDevTools()),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
