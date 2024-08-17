import 'package:flutter/material.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu_seva/datatypes.dart';
import 'package:intl/intl.dart';
import 'package:synchronized/synchronized.dart';

class DistTiles extends StatefulWidget {
  const DistTiles({super.key});

  @override
  State<DistTiles> createState() => _DistTilesState();
}

// hint: DistTilesKey.currentState!.refresh();
final GlobalKey<_DistTilesState> DistTilesKey = GlobalKey<_DistTilesState>();

class _DistTilesState extends State<DistTiles> {
  final _lockInit = Lock();
  List<LadduDist> dists = [];

  Future<void> _futureInit() async {
    await _lockInit.synchronized(() async {
      dists = await FB().readLadduDists(date: DateTime.now());
      dists.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  Future<void> refresh() async {
    await _futureInit();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _futureInit(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Container(
            height: 80, // Adjust the height as needed
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dists.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Container(
                    width: 100, // Adjust the width as needed
                    child: Column(
                      children: [
                        SizedBox(height: 6.0),
                        Text(
                            DateFormat('HH:mm').format(dists[index].timestamp)),
                        Container(
                          padding:
                              EdgeInsets.all(8.0), // Adjust padding as needed
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color ??
                                  Colors.black, // Adjust border color as needed
                              width: 2.0, // Adjust border width as needed
                            ),
                          ),
                          child: Text(
                            dists[index].count.toString(),
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
