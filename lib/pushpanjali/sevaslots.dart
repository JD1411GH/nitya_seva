import 'package:flutter/material.dart';
import 'package:garuda/pushpanjali/datatypes.dart';

class SevaSlots extends StatefulWidget {
  const SevaSlots({super.key});

  @override
  State<SevaSlots> createState() => _WidgetTemplateState();
}

class _WidgetTemplateState extends State<SevaSlots> {
  List<SevaSlot> sevaSlots = [];

  Future<void> _futureInit() async {}

  Future<void> refresh() async {
    await _futureInit();
    setState(() {});
  }

  Widget _getSevaSlotWidgets() {
    return ListView.builder(
      itemCount: sevaSlots.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(sevaSlots[index].title),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh,
      child: FutureBuilder<void>(
        future: _futureInit(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return sevaSlots.isEmpty
                ? const Center(
                    child: Text('No slots available'),
                  )
                : _getSevaSlotWidgets();
          }
        },
      ),
    );
  }
}
