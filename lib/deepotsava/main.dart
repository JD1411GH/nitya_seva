import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class Deepotsava extends StatefulWidget {
  @override
  _DeepotsavaState createState() => _DeepotsavaState();
}

class _DeepotsavaState extends State<Deepotsava> {
  Card _rkcSalesCard = Card();
  Card _rrgSalesCard = Card();
  Card _deepamMakingCard = Card();
  Card _inventoryCard = Card();

  double cardWidth = 300;
  double cardHeight = 100;
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
    _rkcSalesCard = Card(
      color: Colors.amber, // Set the background color to golden
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Add padding around the content
        child: Container(
          width: cardWidth,
          height: cardHeight,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text('RKC Deepam Sales'),
                ),
                SizedBox(width: 10), // Add some space between text and image
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                      10.0), // Set the border radius to a smaller value
                  child: Image.asset(
                    'assets/images/RKC.png', // Replace with your image path
                    width: 80, // Set the width of the image
                    height: 80, // Set the height of the image
                    fit: BoxFit
                        .contain, // Ensure the image fits within the container
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    setState(() {});
  }

  void _animateCards() {
    double screenWidth = MediaQuery.of(context).size.width;
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
              child: _rkcSalesCard,
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 500),
              left: _isVisible[1] ? _positions[1].dx : -100,
              top: _isVisible[1] ? _positions[1].dy : -100,
              child: _rrgSalesCard,
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 500),
              left: _isVisible[2] ? _positions[2].dx : -100,
              top: _isVisible[2] ? _positions[2].dy : -100,
              child: _deepamMakingCard,
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 500),
              left: _isVisible[3] ? _positions[3].dx : -100,
              top: _isVisible[3] ? _positions[3].dy : -100,
              child: _inventoryCard,
            ),
          ],
        ),
      ),
    );
  }
}
