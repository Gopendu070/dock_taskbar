import 'dart:async';

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
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var animatedW = 48.0;
  void animateCon() {
    setState(() {
      if (animatedW == 48.0) {
        animatedW = 0.0;
      }
      Timer(Duration(milliseconds: 400), () {
        animatedW = 48.0;
      });
    });
  }

  void resetCon() {
    setState(() {
      if (animatedW == 0.0) {
        animatedW = 48.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade500,
      body: Center(
        child: Dock(
          items: const [
            Icons.person,
            Icons.message,
            Icons.call,
            Icons.camera,
            Icons.photo,
          ],
          onDragUpdateCallback: animateCon,
          builder: (icon, scale) {
            return AnimatedScale(
              scale: scale,
              duration: const Duration(milliseconds: 100),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                // constraints: const BoxConstraints(minWidth:(icon == Icons.abc) ? 0: 48),
                width: icon == Icons.abc ? animatedW : 48,
                height: icon == Icons.abc ? animatedW : 48,
                margin: icon == Icons.abc ? null : EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: icon == Icons.abc
                      ? Colors.transparent
                      : Colors
                          .primaries[icon.hashCode % Colors.primaries.length],
                ),
                child: Center(
                    child: icon == Icons.abc
                        ? Container(
                            height: 48,
                            width: 48,
                            color: Colors.transparent,
                          )
                        : Icon(icon, color: Colors.white)),
              ),
            );
          },
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
    required this.onDragUpdateCallback,
  });

  final List<T> items;
  final Widget Function(T item, double scale) builder;
  final VoidCallback onDragUpdateCallback;
  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T extends Object> extends State<Dock<T>> {
  late List<T> _items;
  T? _draggedItem;
  int? _initialIndex;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _items = widget.items.toList();
  }

  late double pos;
  bool isDragged = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: MediaQuery.of(context).size.width - 100,
          margin: const EdgeInsets.all(6),
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

                return MouseRegion(
                  onEnter: (_) => setState(() => _hoveredIndex = index),
                  onExit: (_) => setState(() => _hoveredIndex = null),
                  child: LongPressDraggable<T>(
                    data: item,
                    onDragStarted: () {
                      setState(() {
                        _draggedItem = item;
                        _initialIndex = index;
                        _items.remove(item);
                        print(_items.length);
                        // after removing the item I can insert a blak container to maintain the space
                        _items.insert(
                            index,
                            Icons.abc
                                as T); // Icons.abc would be used as a flag
                        // Timer(Duration(milliseconds: 20), () {
                        //   animateContainer();
                        // });

                        // Timer(Duration(milliseconds: 300), () {
                        //   _items.removeAt(index);
                        // });
                        // // Timer(Duration(milliseconds: 350), resetContainer);
                        // resetContainer();
                      });
                    },
                    onDragUpdate: (details) {
                      // Set isDragging to true whenever the item is actively being dragged
                      // setState(() {
                      //   isDragging = true;
                      // });
                      // print("dragging");
                      if (!isDragged) {
                        pos = details.globalPosition.dy;
                        isDragged = true;
                      }
                      print(pos);
                      if (details.globalPosition.dy < pos - 48) {
                        print("up drag ${details.globalPosition.dy}");
                        widget.onDragUpdateCallback();
                        Timer(Duration(milliseconds: 270), () {
                          _items.remove(Icons.abc);
                        });
                      }
                      if (details.globalPosition.dy > pos + 48) {
                        print("down drag ${details.globalPosition.dy}");
                        widget.onDragUpdateCallback();
                        Timer(Duration(milliseconds: 270), () {
                          _items.remove(Icons.abc);
                        });
                      }
                    },
                    onDragEnd: (_) {
                      print("end-----------");
                      print(_items.length);
                      setState(() {
                        if (_draggedItem != null &&
                            !_items.contains(_draggedItem)) {
                          _items.insert(_initialIndex!, _draggedItem!);
                        }
                        _draggedItem = null;
                        _initialIndex = null;
                      });
                    },
                    onDraggableCanceled: (_, __) {
                      print("object");
                      setState(() {
                        _items.remove(Icons.abc);
                        if (_draggedItem != null) {
                          _items.insert(_initialIndex!, _draggedItem!);

                          _draggedItem = null;
                          _initialIndex = null;
                        }
                      });
                    },
                    feedback: Material(
                      color: Colors.transparent,
                      child: widget.builder(item, 1.2),
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
                        if (_draggedItem == item) {
                          return Container(
                            width: 48,
                            height: 48,
                            color: Colors.lightBlue,
                          );
                        } else {
                          final scale = (_hoveredIndex == index) ? 1.2 : 1.0;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 20),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: widget.builder(item, scale),
                          );
                        }
                      },
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
