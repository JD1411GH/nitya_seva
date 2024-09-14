import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class Deepotsava extends StatefulWidget {
  @override
  _DeepotsavaState createState() => _DeepotsavaState();
}

class _DeepotsavaState extends State<Deepotsava> {
  Card _rkcCard = Card();

  List<bool> _isVisible = [false, false, false, false];
  List<Offset> _positions = [
    Offset(0, 0),
    Offset(0, 0),
    Offset(0, 0),
    Offset(0, 0)
  ];
  Random _random = Random();

  @override
  void initState() {
    super.initState();
    _refresh();
    WidgetsBinding.instance.addPostFrameCallback((_) => _animateCards());
  }

  Future<void> _refresh() async {
    _rkcCard = Card(
      child: Container(
        width: 250,
        height: 100,
        child: Center(child: Text('RKC Deepam Counter')),
      ),
    );

    setState(() {});
  }

  void _animateCards() {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth * 0.7; // 70% of the screen width
    double cardHeight = 100;
    double centerX = (screenWidth - cardWidth) / 2;
    double topPadding = 50;

    for (int i = 0; i < 4; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        setState(() {
          _isVisible[i] = true;
          _positions[i] = _random.nextBool()
              ? Offset(0, topPadding + i * (cardHeight + 20))
              : Offset(
                  screenWidth - cardWidth, topPadding + i * (cardHeight + 20));
        });

        Future.delayed(Duration(milliseconds: 500), () {
          setState(() {
            _positions[i] = Offset(centerX, topPadding + i * (cardHeight + 20));
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deepotsava'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: Duration(milliseconds: 500),
              left: _isVisible[0] ? _positions[0].dx : -100,
              top: _isVisible[0] ? _positions[0].dy : -100,
              child: _rkcCard,
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 500),
              left: _isVisible[1] ? _positions[1].dx : -100,
              top: _isVisible[1] ? _positions[1].dy : -100,
              child: Card(
                child: Container(
                  width: 250,
                  height: 100,
                  child: Center(child: Text('Card 2')),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 500),
              left: _isVisible[2] ? _positions[2].dx : -100,
              top: _isVisible[2] ? _positions[2].dy : -100,
              child: Card(
                child: Container(
                  width: 250,
                  height: 100,
                  child: Center(child: Text('Card 3')),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 500),
              left: _isVisible[3] ? _positions[3].dx : -100,
              top: _isVisible[3] ? _positions[3].dy : -100,
              child: Card(
                child: Container(
                  width: 250,
                  height: 100,
                  child: Center(child: Text('Card 4')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
