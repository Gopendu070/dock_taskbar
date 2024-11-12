import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.blueGrey.shade400,
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (icon, scale) {
              return AnimatedScale(
                scale: scale,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  constraints: const BoxConstraints(minWidth: 48),
                  height: 48,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors
                        .primaries[icon.hashCode % Colors.primaries.length],
                  ),
                  child: Center(child: Icon(icon, color: Colors.white)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<T> items;

  final Widget Function(T item, double scale) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T extends Object> extends State<Dock<T>> {
  late List<T> _items;
  T? _draggedItem;
  int? _initialIndex;

  @override
  void initState() {
    super.initState();
    _items = widget.items.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(6),
      // width: MediaQuery.of(context).size.width - 15,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_items.length, (index) {
            final item = _items[index];

            return LongPressDraggable<T>(
              data: item,
              onDragStarted: () {
                setState(() {
                  _draggedItem = item;
                  _initialIndex = index;
                  _items.remove(item);
                });
              },
              onDragEnd: (_) {
                setState(() {
                  // Return item to its original position if it hasn't been dropped onto a new position
                  if (_draggedItem != null && !_items.contains(_draggedItem)) {
                    _items.insert(_initialIndex!, _draggedItem!);
                  }
                  _draggedItem = null;
                  _initialIndex = null;
                });
              },
              onDraggableCanceled: (_, __) {
                setState(() {
                  if (_draggedItem != null) {
                    _items.insert(_initialIndex!, _draggedItem!);
                    _draggedItem = null;
                    _initialIndex = null;
                  }
                });
              },
              feedback: Material(
                color: Colors.transparent,
                child:
                    widget.builder(item, 1.2), // Slightly larger feedback scale
              ),
              child: DragTarget<T>(
                onWillAccept: (data) => data != item,
                onAccept: (data) {
                  setState(() {
                    final oldIndex = _items.indexOf(data);
                    if (oldIndex != -1) _items.removeAt(oldIndex);
                    _items.insert(index, data);
                    _draggedItem = null;
                    _initialIndex = null;
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  // Only display the item if it is not the dragged item
                  if (_draggedItem == item) {
                    return const SizedBox(width: 48, height: 48);
                  }

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.bounceInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: widget.builder(item, 1.0),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}
